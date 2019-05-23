require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin     = users(:michael)
    @non_admin = users(:archer)
    @non_activated = users(:non_activated)
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination', count: 2
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
  
  test "index only including activated users" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    users = assigns(:users)
    users.each do |user|
      assert user.activated?
    end
    assert_select "a[href=?]", user_path(@non_activated), count: 0
    
    # Todo: users/:id 用のintegration testファイルを作成する？
    get user_path(@non_activated)
    assert_redirected_to root_url
  end
end
