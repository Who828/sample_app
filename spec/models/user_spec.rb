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

	describe "micropost associations" do

     before(:each) do
      @user = User.create(@attr)
      @mp1 = Factory(:micropost, :user => @user, :created_at => 1.day.ago)
      @mp2 = Factory(:micropost, :user => @user, :created_at => 1.hour.ago)
    end

    it "should have a microposts attribute" do
      @user.should respond_to(:microposts)
    end

    it "should have the right microposts in the right order" do
      @user.microposts.should == [@mp2, @mp1]
    end

    it "should destroy associated microposts" do
      @user.destroy
      [@mp1, @mp2].each do |micropost|
        Micropost.find_by_id(micropost.id).should be_nil
      end
    end
    describe "status feed" do

      it "should have a feed" do
        @user.should respond_to(:feed)
      end

      it "should include the user's microposts" do
        @user.feed.should include(@mp1)
        @user.feed.should include(@mp2)
      end
      
      it "should not include a different user's microposts" do
        mp3 = Factory(:micropost,
                      :user => Factory(:user, :email => Factory.next(:email)))
        @user.feed.should_not include(mp3)
      end

      it "should include the microposts of followed users" do
        followed = Factory(:user, :email => Factory.next(:email))
        mp3 = Factory(:micropost, :user => followed)
        @user.follow!(followed)
        @user.feed.should include(mp3)
      end
    end
  end
  describe "relationships" do

    before(:each) do
      @user = User.create!(@attr)
      @followed = Factory(:user)
    end

    it "should have a relationships method" do
      @user.should respond_to(:relationships)
    end

    it "should have a following method" do
      @user.should respond_to(:following)
    end
        it "should have a following? method" do
      @user.should respond_to(:following?)
    end
    
    it "should have a follow! method" do
      @user.should respond_to(:follow!)
    end

    it "should follow another user" do
      @user.follow!(@followed)
      @user.should be_following(@followed)
    end

    it "should include the followed user in the following array" do
      @user.follow!(@followed)
      @user.following.should include(@followed)
    end
     it "should have a reverse_relationships method" do
      @user.should respond_to(:reverse_relationships)
    end
    
    it "should have a followers method" do
      @user.should respond_to(:followers)
    end

    it "should include the follower in the followers array" do
      @user.follow!(@followed)
      @followed.followers.should include(@user)
    end
  end
end



