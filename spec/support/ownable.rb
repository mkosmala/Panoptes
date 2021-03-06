shared_examples "is ownable" do
  it "should be valid with an owner" do
    expect(owned).to be_valid
  end

  it "should not be valid without an owner" do
    expect(not_owned).to_not be_valid
  end

  describe "#owner?" do
    it "should return truthy when passed its owner object" do
      expect(owned.owner?(owned.owner)).to be_truthy
    end

    it "should be falsy when passed an owner that does not own it" do
      not_the_owner = build(:user)
      expect(owned.owner?(not_the_owner)).to be_falsy
    end
  end
end
