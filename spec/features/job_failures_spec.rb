require "rails_helper"

RSpec.feature "Job failures" do
  before :each do
    Sidekiq::DeadSet.new.clear
  end

  scenario "Admin views all failures" do
    stub_const("Hound::ADMIN_GITHUB_USERNAMES", ["foo-user"])
    user = create(:user, username: "foo-user")
    populate_failures(["Foo error", "Bar error", "Foo error"])

    sign_in_as(user)
    visit admin_job_failures_path

    expect(table_row(1)).to have_failures("2 Foo error")
    expect(table_row(2)).to have_failures("1 Bar error")
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
    find("tr:nth-of-type(1) input[type=submit]").click

    expect(table_row(1)).to have_failures("1 Bar error")
    expect(page).not_to have_text("Foo error")
  end

  def populate_failures(messages)
    dead_set = Sidekiq::DeadSet.new
    messages.each_with_index do |message, index|
      job = {
        jid: index.to_s,
        error_message: message,
        failed_at: Time.current.to_i,
      }
      dead_set.schedule(Time.current, job)
    end
  end

  def have_failures(text)
    have_text(text)
  end

  def table_row(position)
    find("tbody tr:nth-of-type(#{position})")
  end
end
