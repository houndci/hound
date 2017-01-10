require "rails_helper"

feature "Job failures" do
  QUEUE_NAME = "test-job-failures".freeze

  around :each do |example|
    previous_backend = Resque::Failure.backend
    Resque::Failure.backend = Resque::Failure::Redis
    cleanup_test_failures

    example.call

    cleanup_test_failures
    Resque::Failure.backend = previous_backend
  end

  scenario "Admin views all failures" do
    stub_const("Hound::ADMIN_GITHUB_USERNAMES", ["foo-user"])
    user = create(:user, username: "foo-user")
    populate_failures(["Foo error", "Bar error", "Foo error"])

    sign_in_as(user)
    visit admin_job_failures_path

    expect(table_row(1)).to have_failures("Foo error 0, 2")
    expect(table_row(2)).to have_failures("Bar error 1")
  end

  scenario "Cannot access as a non-admin user" do
    user = create(:user)
    populate_failures(["Foo error"])

    sign_in_as(user)
    visit admin_job_failures_path

    expect(current_path).to eq repos_path
    expect(page).to have_no_text("Foo error")
  end

  scenario "Admin removes job failures" do
    stub_const("Hound::ADMIN_GITHUB_USERNAMES", ["foo-user"])
    user = create(:user, username: "foo-user")
    populate_failures(["Foo error", "Bar error", "Foo error"])

    sign_in_as(user)
    visit admin_job_failures_path
    find("tr:nth-of-type(1) a").click

    expect(table_row(1)).to have_failures("Bar error 0")
    expect(page).not_to have_text("Foo error")
  end

  def populate_failures(messages)
    messages.each do |message|
      Resque::Failure.create(
        exception: StandardError.new(message),
        payload: {},
        queue: QUEUE_NAME,
      )
    end
  end

  def cleanup_test_failures
    Resque::Failure.remove_queue(QUEUE_NAME)
  end

  def have_failures(text)
    have_text(text)
  end

  def table_row(position)
    find("tbody tr:nth-of-type(#{position})")
  end
end
