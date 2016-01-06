describe ObjectStore do

  RSpec::Matchers.define :be_success do |with_message: '', and_result: false|
    match do |actual|
      without_result = actual.message == with_message &&
        actual.success? == true &&
        actual.error? == false

      return without_result unless and_result

      without_result && actual.result == and_result
    end
  end

  RSpec::Matchers.define :be_failure do |with_message: '', and_result: false|
    match do |actual|
      without_result = actual.message == with_message &&
        actual.success? == false &&
        actual.error? == true
      return without_result unless and_result

      without_result && actual.result == and_result
    end
  end

  it "can commit objects" do
    repo = ObjectStore.init
    repo.add("object1", "content1")
    repo.add("object2", "content2")
    expect(repo.commit("So cool!")).to be_success with_message: "So cool!\n\t2 objects changed", and_result: repo.head.result
  end

  describe '#init' do

    let(:repo) { ObjectStore.init }

    it 'creates new branch named `master`' do
      expect(repo.branch.list).to be_success with_message: '* master'
    end

    it 'returns self if initialized with a block' do
      repo = ObjectStore.init do
        add("value", 21)
        commit("message")
      end
      expect(repo).to be_instance_of(ObjectStore)
    end

    it 'can be initialized with a block' do
      repo = ObjectStore.init do
        add("value", 21)
        commit("message")
      end
      expect(repo.head).to be_success with_message: "message"
    end
  end

  describe '#log' do

    it 'does not log anything if no commits' do
      repo = ObjectStore.init
      repo.branch.checkout('master')
      expect(repo.log).to be_failure with_message: 'Branch master does not have any commits yet.'
    end

    it 'logs the commits in the current branch in reverse order' do
      repo = ObjectStore.init
      repo.add('foo1', :bar1)
      first_commit = repo.commit('First commit')

      repo.add('foo2', :bar2)
      second_commit = repo.commit('Second commit')

      message = <<-EOS
Commit #{second_commit.result.hash}
Date: #{second_commit.result.date.strftime('%a %b %-d %H:%M %Y %z')}

\tSecond commit

Commit #{first_commit.result.hash}
Date: #{first_commit.result.date.strftime('%a %b %-d %H:%M %Y %z')}

\tFirst commit
EOS

      expect(repo.log).to be_success with_message: message.chomp

    end
  end

  describe '#checkout' do

    let(:repo) { ObjectStore.init }

    it 'can not checkout non existing commit' do
      expect(repo.checkout('blah')).to be_failure with_message: 'Commit blah does not exist.'
    end

    it 'can checkout existing commit' do
      repo.add('important', 'stuff')
      prev_commit = repo.commit('test message').result
      repo.add('slot', 'mlon')
      repo.commit('another test message')
      repo.remove('important')
      expect(repo.checkout(prev_commit.hash)).to be_success with_message: "HEAD is now at #{prev_commit.hash}.", and_result: prev_commit
    end

  end

  describe '#add' do

    let(:repo) { ObjectStore.init }

    it 'can add stuff' do
      expect(repo.add("important", "this is my first version.")).to be_success with_message: 'Added important to stage.', and_result: 'this is my first version.'
    end
  end

  describe '#commit' do

    let(:repo) { ObjectStore.init }

    it 'can not commit changes if there is no any' do
      expect(repo.commit("A commit message goes here...")).to be_failure with_message: 'Nothing to commit, working directory clean.'
    end

    it 'can commit changes' do
      repo.add('important', 'stuff')
      repo.add('slot', 'mlon')
      expect(repo.commit("A commit message goes here...")).to be_success with_message: "A commit message goes here...\n\t2 objects changed"
    end
  end

  describe '#get' do

    let(:repo) { ObjectStore.init }

    it 'can not return uncommited object' do
      expect(repo.get('important')).to be_failure with_message: 'Object important is not committed.'
    end

    it 'can return commited object' do
      repo.add('important', 'stuff')
      repo.add('slot', 'mlon')
      repo.commit("A commit message goes here...")
      expect(repo.get('slot')).to be_success with_message: 'Found object slot.', and_result: 'mlon'
    end

    it 'can not return commited and removed object' do
      repo.add('important', 'stuff')
      repo.add('slot', 'mlon')
      repo.commit("A commit message goes here...")
      repo.remove('slot')
      repo.commit("Another commit message goes here...")
      expect(repo.get('slot')).to be_failure with_message: 'Object slot is not committed.'
    end

  end

  describe '#remove' do

    let(:repo) { ObjectStore.init }

    it 'can not remove uncommited objects' do
      expect(repo.remove('slon')).to be_failure with_message: 'Object slon is not committed.'
    end

    it 'can commit removals' do
      repo.add('important', 'stuff')
      repo.commit('test message')
      repo.add('slot', 'mlon')
      repo.commit('another test message')
      repo.remove('important')
      expect(repo.commit("A commit message goes here...")).to be_success with_message: "A commit message goes here...\n\t1 objects changed"
    end
  end

  describe '#head' do

    let(:head_result) do
      repo = ObjectStore.init
      repo.add('important', 'stuff')
      repo.commit('test message')
      repo.add('slot', 'mlon')
      repo.commit('another test message')
      repo.head.result
    end

    it 'responds to head' do
      expect(ObjectStore.init).to respond_to :head
    end

    describe '#date' do

      it 'responds to date' do
        expect(head_result).to respond_to(:date)

      end

      it 'returns the date as Time object' do
        expect(head_result.date).to be_instance_of Time
      end
    end

    describe '#message' do

      it 'responds to message' do
        expect(head_result).to respond_to(:message)

      end

      it 'returns the message of the last commit' do
        expect(head_result.message).to eq 'another test message'
      end
    end

    describe '#hash' do

      it 'responds to hash' do
        expect(head_result).to respond_to(:hash)

      end

      # can not test the hash without exposing the realisation
    end


    describe '#objects' do

      it 'responds to objects' do
        expect(head_result).to respond_to(:objects)
      end

      it 'returns an Array with the committed objects' do
        expect(head_result.objects).to be_instance_of Array
        expect(head_result.objects.size).to eq 2
      end

      it 'does not return removed objects' do
        repo = ObjectStore.init
        repo.add('important', 'stuff')
        repo.commit('test message')
        repo.add('slot', 'mlon')
        repo.commit('another test message')
        repo.remove('slot')
        repo.commit('removing slot')

        expect(repo.head.result.objects.size).to eq 1
      end
    end
  end

  describe '#branch' do

    it 'responds to branch' do
      expect(ObjectStore.init).to respond_to :branch
    end

    let(:branch) { ObjectStore.init.branch }

    describe '#list' do

      it 'can list branches' do
        expect(branch.list).to be_success with_message: '* master'
      end
    end

    describe '#create' do

      it 'can create branches' do
        expect(branch.create('develop')).to be_success with_message: 'Created branch develop.'
      end

      it 'can not create existing branches' do
        expect(branch.create('master')).to be_failure with_message: 'Branch master already exists.'
      end
    end

    describe '#ceckout' do

      it 'can not checkout non existing branch' do
        expect(branch.checkout('develop')).to be_failure with_message: 'Branch develop does not exist.'
      end

      it 'can checkout an existing branch' do
        branch.create('develop')
        expect(branch.checkout('develop')).to be_success with_message: 'Switched to branch develop.'
      end
    end

    describe '#remove' do

      it 'can not remove the current branch' do
        expect(branch.remove('master')).to be_failure with_message: 'Cannot remove current branch.'
      end

      it 'can not remove non existing branch' do
        expect(branch.remove('develop')).to be_failure with_message: 'Branch develop does not exist.'
      end

      it 'can remove non branch which is not current' do
        branch.create('develop')
        expect(branch.list.message).to include('develop')
        expect(branch.remove('develop')).to be_success with_message: 'Removed branch develop.'
        expect(branch.list.message).not_to include('develop')
      end
    end
  end
end
