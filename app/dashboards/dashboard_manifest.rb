# frozen_string_literal: true

class DashboardManifest
  DASHBOARDS = [
    :blacklisted_pull_requests,
    :job_failures,
    :owners,
  ]
  ROOT_DASHBOARD = :owners
end
