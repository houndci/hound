import EmptyRepoList from '../components/ReposContainer/components/Organization/RepoList'

it('renders an empty unordered list', () => {
  const wrapper = shallow(
    <EmptyRepoList />
  )
  expect(wrapper).toMatchSnapshot()
})
