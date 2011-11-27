# == Schema Information
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe User do
	before(:each) do
		@attr = { :name => "Smit Shah", :email => "who828@gmail.com"}
	end
	it "should create an user for given valid attributes" do
		User.create!(@attr)
	end
	it "should require a name" do
		no_name_user = User.create(@attr.merge(:name => ""))
		no_name_user.should_not be_valid
	end
	it "should require an email address" do
		no_email_user = User.create(@attr.merge(:email => ""))
		no_email_user.should_not be_valid
	end
	it "should reject names that are long" do
		long_name = "a" * 51
		long_user_name = User.create(@attr.merge(:name => long_name))
		long_user_name.should_not be_valid
	end
	it "should accept vaild email address" do
		addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]		
		addresses.each do |address|
			valid_email = User.create(@attr.merge(:email => address))
			valid_email.should be_valid
		end
	end
	it "should not accept invaild email address" do
		addresses = %w[user@foo,com THE_USER@foo.org,first.last@foo.]
		addresses.each do |address|
			invalid_email = User.create(@attr.merge(:email => address))
			invalid_email.should_not be_valid
		end
	end
  	it "should reject duplicate email addresses" do
  		User.create!(@attr)
  		User_with_duplicate_email = User.new(@attr)
        User_with_duplicate_email.should_not be_valid
    end
    it "should reject identical email addresses up to case" do
  		upcase_email = @attr[:email].upcase
  		User.create(@attr.merge(:email => upcase_email))
  		User_with_upcase_email = User.new(@attr)
        User_with_upcase_email.should_not be_valid
    end
end

