require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase

  context "the controller" do
    should_eventually "test helper :all"
    # should have_helper_method :logged_in?, :admin_logged_in?, :current_user_session, :current_user
    should filter_params :password, :password_confirmation
    should protect_from_forgery
  end

  context "#logged_in?" do
    should "return true if there is a user session" do
      @the_user = User.generate!
      @the_user.active = true
      @the_user.activated_at = DateTime.now
      @the_user.save!
      UserSession.create(@the_user)
      assert controller.logged_in?
    end

    should "return false if there is no session" do
      assert !controller.logged_in?
    end
  end

  should_eventually "test Admin::Filters module"

  context "#admin_logged_in?" do
    should "return true if there is a user session for an admin" do
      @the_user = User.generate!
      @the_user.add_role("super_user")
      @the_user.active = true
      @the_user.activated_at = DateTime.now
      @the_user.save!
      UserSession.create(@the_user)
      assert controller.admin_logged_in?
    end

    should "return false if there is a user session for a non-admin" do
      @the_user = User.generate!
      @the_user.remove_role("super_user")
      @the_user.active = true
      @the_user.activated_at = DateTime.now
      @the_user.save!
      UserSession.create(@the_user)
      assert !controller.admin_logged_in?
    end

    should "return false if there is no session" do
      assert !controller.admin_logged_in?
    end
  end
end
