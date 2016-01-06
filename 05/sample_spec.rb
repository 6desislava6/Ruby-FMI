describe ObjectStore do
  RSpec::Matchers.define :be_success do |message, result|
    match do |actual|
      actual.message == message &&
      actual.result == result &&
      actual.success? == true &&
      actual.error? == false
    end
  end

  RSpec::Matchers.define :be_failure do |message, result|
    match do |actual|
      actual.message == message &&
      actual.result == result &&
      actual.success? == false &&
      actual.error? == true
    end
  end

  it "can commit objects" do
    repo = ObjectStore.init do
      add("value", 21)
      add("value", 21)
      add("value", 21)
      add("value", 21)
      commit("message")
    end
    repo.add("object1", "content1")
    repo.add("object2", "content2")
    expect(repo.commit("So cool!")).to be_success("So cool!\n\t2 objects changed", repo.head.result)
  end

    it "impossible commit" do
    repo = ObjectStore.init
    expect(repo.commit("So cool!")).to be_failure("Nothing to commit, working directory clean.", repo.head.result)
  end

  it 'can remove objects' do
    repo = ObjectStore.init do
      add("value", 21)
      commit("message")
    end
    expect(repo.remove("value").result).to eq 21
    expect(repo.commit("This was not that important after all")).to be_success("This was not that important after all\n\t1 objects changed", repo.head.result)
  end

  it 'impossible removal' do
    repo = ObjectStore.init
    result = repo.remove("value")
    expect(result).to be_failure("Object value is not committed.", repo.head.result)
  end

  it 'impossible removal2' do
    repo = ObjectStore.init do
      add("value", 21)
      commit("message")
    end
    result = repo.remove("value1")
    p result
    expect(result).to be_failure("Object value1 is not committed.", result.result)
  end

  it 'can checkout' do
    repo = ObjectStore.init do
      add("value", 21)
      commit("message")
      add("value2", 22)
      commit("message2")
      add("value3", 23)
      commit("message3")
      add("value4", 24)
      commit("message4")
    end
    commit = repo.branch.current_branch.commits[2]
    expect(repo.checkout(commit.hash)).to be_success("HEAD is now at #{commit.hash}.", commit)
    expect(repo.branch.current_branch.commits.size). to eq 3
    remaining_objects = {"value" => 21, "value2" => 22, "value3" => 23}
    expect(repo.branch.current_branch.commits.last.commit_files). to eq remaining_objects
  end

  it 'impossible checkout' do
    repo = ObjectStore.init do
      add("value", 21)
      commit("message")
      add("value2", 22)
      commit("message2")
      add("value3", 23)
      commit("message3")
      add("value4", 24)
      commit("message4")
    end
    result = repo.checkout("123")
    expect(result).to be_failure("Commit 123 does not exist.", result.result)
  end

  it 'impossible checkout2' do
    repo = ObjectStore.init do
      add("value", 21)
    end
    result = repo.checkout("123")
    expect(result).to be_failure("Commit 123 does not exist.", result.result)
  end

  it 'impossible log' do
    repo = ObjectStore.init do
      add("value", 21)
    end
    result = repo.log
    expect(result).to be_failure("Branch master does not have any commits yet.", result.result)
  end

  it 'can head master' do
    repo = ObjectStore.init do
      add("value", 21)
      commit("message")
      add("value2", 22)
      commit("message2")
      add("value3", 23)
      commit("message3")
      add("value4", 24)
      commit("message4")
    end
    result = repo.head
    expect(result).to be_success("message4", repo.branch.current_branch.commits.last)
  end

  it 'impossible head master' do
    repo = ObjectStore.init do
      add("value", 21)
      add("value2", 22)
      add("value3", 23)
      add("value4", 24)
    end
    result = repo.head
    expect(result).to be_failure("Branch master does not have any commits yet.", repo.branch.current_branch.commits.last)
  end


  it 'can get object' do
    repo = ObjectStore.init do
      add("value", 21)
      add("value2", 22)
      add("value3", 23)
      add("value4", 24)
      commit("message")
    end
    result = repo.get("value2")
    expect(result).to be_success("Found object value2.", result.result)
  end

    it 'can"t get object' do
    repo = ObjectStore.init do
      add("value", 21)
      add("value2", 22)
      add("value3", 23)
      add("value4", 24)
    end
    result = repo.get("value2")
    expect(result).to be_failure("Object value2 is not committed.", result.result)
  end

    it 'can"t get object2' do
    repo = ObjectStore.init do
      add("value", 21)
      commit("blaa")
      add("value2", 22)
      add("value3", 23)
      add("value4", 24)
    end
    result = repo.get("value2")
    expect(result).to be_failure("Object value2 is not committed.", result.result)
  end

  it 'can create branch' do
    repo = ObjectStore.init do
      add("value", 21)
      commit("blaa")
    end
    expect(repo.branch.branches.size).to eq 1

    result = repo.branch.create("develop")
    expect(result.message).to eq("Created branch develop.")
    expect(result.success?).to be true
    expect(result.error?).to be false
    expect(repo.branch.branches.size).to eq 2
  end


  it 'can create 2 branches' do
    repo = ObjectStore.init do
      add("value", 21)
      commit("blaa")
      branch.create("haha")
    end
    expect(repo.branch.branches.size).to eq 2

    result = repo.branch.create("develop")
    expect(result.message).to eq("Created branch develop.")
    expect(result.success?).to be true
    expect(result.error?).to be false
    expect(repo.branch.branches.size).to eq 3
    #p repo.branch.current_branch.commits
    #p repo.branch.branches
    #p repo.branch.branches[:master].commits
    expect(repo.branch.current_branch.commits).to eq repo.branch.branches[:master].commits
  end

  it 'impossible branch creation' do
    repo = ObjectStore.init do
      add("value", 21)
      commit("blaa")
      branch.create("haha")
    end
    result = repo.branch.create("haha")
    expect(result.message).to eq("Branch haha already exists.")
  end

    it 'can checkout' do
    repo = ObjectStore.init do
      add("value", 21)
      commit("blaa")
      branch.create("develop")
    end
    result = repo.branch.checkout("develop")
    expect(result).to be_success("Switched to branch develop.", result.result)
  end

    it 'can checkout2' do
    repo = ObjectStore.init do
      add("value", 21)
      commit("blaa")
      branch.create("develop")
      branch.create("develop1")
      branch.create("develop2")
    end
    result = repo.branch.checkout("develop1")
    expect(result).to be_success("Switched to branch develop1.", result.result)
  end

  it 'impossible checkout' do
    repo = ObjectStore.init do
      add("value", 21)
      commit("blaa")
      branch.create("develop")
      branch.create("develop1")
      branch.create("develop2")
    end
    result = repo.branch.checkout("develop3")
    expect(result).to be_failure("Branch develop3 does not exist.", result.result)
  end

  it 'remove branch' do
    repo = ObjectStore.init do
      add("value", 21)
      commit("blaa")
      branch.create("develop")
      branch.create("develop1")
      branch.create("develop2")
    end
    result = repo.branch.remove("develop")
    expect(result).to be_success("Removed branch develop.", result.result)
  end


  it 'impossible bracnh removal' do
    repo = ObjectStore.init do
      add("value", 21)
      commit("blaa")
      branch.create("develop")
      branch.create("develop1")
      branch.create("develop2")
      branch.checkout("develop1")
    end
    result = repo.branch.remove("develop1")
    expect(result).to be_failure("Cannot remove current branch.", result.result)
  end


  it 'can list' do
    repo = ObjectStore.init do
      add("value", 21)
      commit("blaa")
      branch.create("develop")
    end
    result = repo.branch.list
    expect(result).to be_success("  develop\n* master", nil)
  end

  it 'can"t log' do
    repo = ObjectStore.init
    repo.add('foo1', :bar1)

    repo.add('foo2', :bar2)
    repo.branch.create("develop")
    repo.branch.checkout("develop")

    result = repo.log
    expect(result).to be_failure("Branch develop does not have any commits yet.", result.result)
  end
end
