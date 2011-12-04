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
		@attr = { :name => "Smit Shah", 
			:email => "who828@gmail.com",
			:password => "foobar",
			:password_confirmation => "foobar"
		}
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
	describe "password validation" do
		it "should require a password" do
			User.new(@attr.merge( :password => "", :password_confirmation => "")).should_not be_valid
		end
		it "should require matching with confirmation" do
			User.new(@attr.merge(:password_confirmation => "invalid")).should_not be_valid
		end	
		it "should reject short password" do
			short = "a" * 5
			hash = @attr.merge( :password => short, :password_confirmation => short)
			User.new(hash).should_not be_valid
		end
		it "should reject long password" do
			long = "a" * 41
			hash = @attr.merge( :password => long, :password_confirmation => long)
			User.new(hash).should_not be_valid
		end
	end
	describe "password encryption" do
		before (:each) do
			@user = User.create!(@attr)
		end

		it "should have an encrypted password" do
			@user.should respond_to(:encrypted_password)
		end
		it "should set the encrypted password" do
			@user.encrypted_password.should_not be_blank
		end
		describe "has_password? method" do
			it "should be true if the passwords match" do
				@user.has_password?(@attr[:password]).should be_true
			end
			it "should be false if the passwords don't match" do
				@user.has_password?("invalid").should be_false
			end
		end
		describe "authenticate method" do

			it "should return nill if email/password mismatch" do
				wrong_password_user = User.authenticate(@attr[:email],"wrongpass")
				wrong_password_user.should be_nil
			end
			it "should return nill if email with no user" do
				wrong_password_user = User.authenticate("xyz@who.com",@attr[:password])
				wrong_password_user.should be_nil
			end
			it "should return user if email/password match" do
				wrong_password_user = User.authenticate(@attr[:email],@attr[:password])
				wrong_password_user.should == @user
			end
		end
	end
	describe "admin attribute" do

		before(:each) do
			@user = User.create!(@attr)
		end

		it "should respond to admin" do
			@user.should respond_to(:admin)
		end

		it "should not be an admin by default" do
			@user.should_not be_admin
		end

		it "should be convertible to an admin" do
			@user.toggle!(:admin)
			@user.should be_admin
		end
	end
end



