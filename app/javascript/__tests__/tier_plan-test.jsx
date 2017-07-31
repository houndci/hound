import TierPlan from '../components/NotifyTierChange/components/TierPlan'

it('renders appropriately (current plan)', () => {
  const plan = {
    name: "Chihuahua",
    price: 49,
    allowance: 4,
    current: true
  }

  const wrapper = shallow(
    <TierPlan
      isCurrent={true}
      isNew={true}
      key={plan.name}
      plan={plan}
    />
  )
  expect(wrapper).toMatchSnapshot()
})

it('renders appropriately (new plan)', () => {
  const plan = {
    name: "Chihuahua",
    price: 49,
    allowance: 4,
    current: false
  }

  const wrapper = shallow(
    <TierPlan
      isCurrent={false}
      isNew={true}
      key={plan.name}
      plan={plan}
    />
  )
  expect(wrapper).toMatchSnapshot()
})

it('renders appropriately (neither current nor new plan)', () => {
  const plan = {
    name: "Chihuahua",
    price: 49,
    allowance: 4,
    current: false
  }

  const wrapper = shallow(
    <TierPlan
      isCurrent={false}
      isNew={false}
      key={plan.name}
      plan={plan}
    />
  )
  expect(wrapper).toMatchSnapshot()
})


it('renders appropriately (bulk)', () => {
  const plan = {
    name: "Bulk",
    price: 0,
    allowance: 0,
    current: true
  }

  const wrapper = shallow(
    <TierPlan
      isCurrent={true}
      isNew={true}
      key={plan.name}
      plan={plan}
    />
  )
  expect(wrapper).toMatchSnapshot()
})
