import NotifyTierChange from '../components/NotifyTierChange'

let repo = {id: 1, name: "Test repo"}
let plans = [
  { name: "Chihuahua", price: 49, allowance: 4 },
  { name: "Labrador", price: 99, allowance: 10 },
  { name: "Great Dane", price: 249, allowance: 30 },
]

function make_active_plan(target_name) {
  return _.map(plans, (plan) => {
    if (plan.name === target_name) {
      plan.current = true
      return plan
    } else {
      plan.current = false
      return plan
    }
  })
}

describe('NotifyTierChange', () => {
  describe('snapshots', () => {
    it('renders plans appropriately (Chihuahua -> Labrador)', () => {
      plans = make_active_plan("Chihuahua")

      const wrapper = shallow(
        <NotifyTierChange
          authenticity_token = "csrf_token"
          plans = {plans}
          repo_id = {repo.id}
          repo_name = {repo.name}
        />
      )
      expect(wrapper).toMatchSnapshot()
    })

    it('renders plans appropriately (Labrador -> Great Dane)', () => {
      plans = make_active_plan("Labrador")

      const wrapper = shallow(
        <NotifyTierChange
          authenticity_token = "csrf_token"
          plans = {plans}
          repo_id = {repo.id}
          repo_name = {repo.name}
        />
      )
      expect(wrapper).toMatchSnapshot()
    })
  })
})
