import RepoTools from '../components/ReposContainer/components/RepoTools'

it('renders appropriately without Show Private button (not syncing)', () => {
  const has_private_access = true

  const wrapper = shallow(
    <RepoTools
      showPrivateButton={!has_private_access}
      onSearchInput={(event) => jest.fn()}
      onRefreshClicked={(event) => jest.fn()}
      onPrivateClicked={(event) => jest.fn()}
      isSyncing={false}
    />
  )
  expect(wrapper).toMatchSnapshot()
})

it('renders appropriately with Show Private button (not syncing)', () => {
  const has_private_access = false

  const wrapper = shallow(
    <RepoTools
      showPrivateButton={!has_private_access}
      onSearchInput={(event) => jest.fn()}
      onRefreshClicked={(event) => jest.fn()}
      onPrivateClicked={(event) => jest.fn()}
      isSyncing={false}
    />
  )
  expect(wrapper).toMatchSnapshot()
})
