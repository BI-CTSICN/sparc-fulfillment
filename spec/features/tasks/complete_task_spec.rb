require "rails_helper"

feature "Completing a Task", js: true do

  scenario "User sets a Task as complete" do
    as_a_user_who_has_an_assigned_task
    when_i_mark_the_task_as_complete
    i_should_not_see_the_task
  end

  def as_a_user_who_has_an_assigned_task
    assignee = User.first
    assignor = create(:user)
    create_list(:task, 2, user: assignor, assignee: assignee)

    visit tasks_path
  end

  def when_i_mark_the_task_as_complete
    first('input.complete').click
  end

  def i_should_not_see_the_task
    expect(page).to have_css("table.tasks tbody tr", count: 1)
  end
end