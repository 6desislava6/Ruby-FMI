require 'time'
require 'digest/sha1'


class ObjectStore

  class Result
    attr_reader :message, :result
    attr_writer :result

    def initialize(message, success, error, result = nil)
      @message = message
      @success = success
      @error = error
      @result = result
    end

    def success?
      @success
    end

    def error?
      @error
    end
  end

  class Repository

    class Commit
      attr_accessor :commit_files
      attr_reader :message, :date, :hash

      def initialize(files, hash, message, date)
        @hash = hash
        @commit_files = files
        @message = message
        @date = date
      end

      def objects
        @commit_files.values
      end
    end

    class Branch
      attr_accessor :added_files, :removed_files, :changed_files, :commits
      attr_reader :name

      def initialize(name, commits = [])
        @name = name
        @commits = commits
      end

      def remove_file(name)
          removed = @commits.last.commit_files[name]
          Result.new("Added #{name} for removal." , true, false, removed)
      end

      def make_new_commit(message, date, commit_files, changed_files)
        hash = Digest::SHA1.hexdigest(date.to_s + message)
        @commits << Commit.new(commit_files, hash, message, date)
        result = Result.new("#{message}\n\t#{changed_files} objects changed",
         true, false, @commits.last)
      end

      def checkout(hash)
        index_commit = @commits.index{|x| x.hash == hash}
        if index_commit.nil?
          Result.new("Commit #{hash} does not exist.", false, true)
        else
          @commits = @commits.take(index_commit + 1)
          Result.new("HEAD is now at #{hash}.", true, false, @commits.last)
        end
      end
    end

    class BranchManager

      attr_reader :current_branch, :branches
      def initialize
        @current_branch = Branch.new("master")
        @branches = {"master": @current_branch}
        @added_files = {}
        @removed_files = {}
        @changed_files = 0
      end

      def add(name, object)
        @changed_files += 1 unless @added_files.has_key?(name)
        @added_files[name] = object
        message = "Added #{name} to stage."
        Result.new(message, true, false, object)
      end

      def clean_files
        @added_files = {}
        @removed_files = []
        @changed_files = 0
      end

      def remove_extra(name)
        @removed_files << name
        @changed_files += 1
      end

      def make_commit_files
        if @current_branch.commits.empty?
          data = @added_files
        else
          data = @current_branch.commits.last.commit_files.merge(@added_files)
        end
        data.delete_if{|key, value| @removed_files.member?(key)}
      end

      def commit(message, date)
        if @changed_files == 0
          return Result.new("Nothing to commit, working directory clean.",
                            false,
                            true)
        end
        result = @current_branch.make_new_commit(message,
                                                 date,
                                                 make_commit_files,
                                                 @changed_files)
        clean_files
        result
      end

      def remove_file(name)
        has_commits = head.success?
        if @added_files.has_key?(name)
          removed = @added_files.delete(name)
          remove_extra(name)
          Result.new("Added #{name} for removal." , true, false, removed)

        elsif has_commits and @current_branch.commits.last.commit_files.
                                                      has_key?(name)
          remove_extra(name)
          @current_branch.remove_file(name)
        else
          return Result.new("Object #{name} is not committed.", false, true)
        end
      end

      def checkout_hash(hash)
        @current_branch.checkout(hash)
      end

      def create(branch_name)
        if @branches.has_key?(branch_name.to_sym)
          Result.new("Branch #{branch_name} already exists.", false, true)
        else
          new_branch = Branch.new(branch_name, @current_branch.commits.clone)
          @branches[branch_name.to_sym] = new_branch
          Result.new("Created branch #{branch_name}.", true, false, new_branch)
        end
      end

      def checkout(branch_name)
        if @branches.has_key?(branch_name.to_sym)
          @current_branch = @branches[branch_name.to_sym]
          Result.new("Switched to branch #{branch_name}.",
                     true,
                     false,
                     @current_branch)
        else
          Result.new("Branch #{branch_name} does not exist.", false, true)
        end
      end

      def remove(branch_name)
        if not @branches.has_key?(branch_name.to_sym)
          Result.new("Branch #{branch_name} does not exist.", false, true)
        elsif @current_branch.name.to_sym == branch_name.to_sym
          Result.new("Cannot remove current branch.", false, true)
        else
          removed_branch = @branches.delete(branch_name.to_sym)
          Result.new("Removed branch #{branch_name}.",
                     true,
                     false,
                     removed_branch)
        end
      end

      def list
        names = @branches.keys.map(&:to_s).sort
        result = names.reduce("") do |message, name|
          if name == @current_branch.name
            message += "\n* " + name
          else
            message += "\n  " + name
          end
        end
        Result.new(result[1..-1], true, false)
      end

      def log
        if @current_branch.commits.empty?
          mess = "Branch #{@current_branch.name} does not have any commits yet."
          Result.new(mess, false, true)
        else
          message = @current_branch.commits.reverse.reduce("") do |mess, commit|
            mess + "Commit #{commit.hash}\n" \
            "Date: #{commit.date.strftime('%a %b %-d %H:%M %Y %z')}" \
            "\n\n\t#{commit.message}" + "\n\n"
          end
          Result.new(message.strip, true, false)
        end
      end

      def head
        if @current_branch.commits.empty?
          Result.new("Branch #{@current_branch.name}" \
            " does not have any commits yet.", false, true)
        else
          last_commit = @current_branch.commits.last
          Result.new(last_commit.message, true, false, last_commit)
        end
      end

      def get(name)
        result_mistake = Result.new("Object #{name} is not committed.",
                                    false,
                                    true)
        if @current_branch.commits.empty?
          return result_mistake
        end

        if @current_branch.commits.last.commit_files.has_key?(name)
          object = @current_branch.commits.last.commit_files[name]
        else
          return result_mistake
        end
        Result.new("Found object #{name}.", true, false, object)
      end
    end

    attr_reader :branch_manager
    def initialize
      @branch_manager = BranchManager.new
    end

    def add(name, object)
      @branch_manager.add(name, object)
    end

    def commit(message)
      date = Time.now #"%a %b %d %H:%M %Y %z"
      @branch_manager.commit(message, date)
    end

    def remove(name)
      @branch_manager.remove_file(name)
    end

    def checkout(hash)
      @branch_manager.checkout_hash(hash)
    end

    def branch
      @branch_manager
    end

    def log
       @branch_manager.log
    end

    def head
      @branch_manager.head
    end

    def get(name)
      @branch_manager.get(name)
    end
  end

  class << self
    def init(&block)
      repo = Repository.new
      return repo if not block_given?
      repo.instance_eval(&block)
      repo
    end
  end
end

repo = ObjectStore.init
repo.add('foo1', :bar1)
repo.commit('First commit')

repo.add('foo2', :bar2)
repo.commit('Second commit')
p repo.branch.create("master").message
puts repo.log.message
# 409  страница
#class_eval sets things up as
#if you were in the body of a class definition, so method definitions will define instance
#methods

#нещо.instance_eval(&block) прави self-а за блока да е нещо-то!
# In contrast, instance_eval  acts as if you were working inside the singleton class of self .
#In Ruby 1.9, constants are now looked up in the scope in which
#instance_eval is called.


#%a - The abbreviated name (``Sun'')
#%b - The abbreviated month name (``Jan'')
#%e - Day of the month, blank-padded ( 1..31)
#%k - Hour of the day, 24-hour clock, blank-padded ( 0..23)
#
#%M - Minute of the hour (00..59)
#%Y - Year with century (can be negative, 4 digits at least)
#          -0001, 0000, 1995, 2009, 14292, etc.
#%z - Time zone as hour and minute offset from UTC (e.g. +0900)
#"%a %b %e %k:%M %Y %z"
# The methods Object#instance_eval , Object#class_eval ,
      # and Object#module_eval let you set
      #self to be some arbitrary object, evaluate the code in
      #a block with, and then reset self
