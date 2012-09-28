# == Schema Information
#
# Table name: social_accounts
#
#  id               :integer          not null, primary key
#  contactable_id   :integer          not null
#  contactable_type :string(255)      not null
#  name             :string(255)      not null
#  label            :string(255)
#  public           :boolean          default(TRUE), not null
#

require 'spec_helper'

describe SocialAccount do
  
  describe ".normalize_label" do
    
    it "reuses existing label" do
      a1 = Fabricate(:social_account, :label => 'Foo')
      a2 = Fabricate(:social_account, :label => 'fOO')
      a2.label.should == 'Foo'
    end
  end
  
  describe "#available_labels" do
    subject { SocialAccount.available_labels }
    it { should include(Settings.social_account.predefined_labels.first) }
    
    it "includes labels from database" do
      a = Fabricate(:social_account, :label => 'Foo')
      should include('Foo')
    end
        
    it "includes labels from database and predefined only once" do
      predef = Settings.social_account.predefined_labels.first
      a = Fabricate(:social_account, :label => predef)
      subject.count(predef).should == 1
    end
  end
end
