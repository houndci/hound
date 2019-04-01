import RepoToolsAdd from '../components/ReposContainer/components/RepoTools/RepoToolsAdd';

describe('RepoToolsAdd component', () => {
  it('renders the button to add repos', () => {
    const wrapper = shallow(<RepoToolsAdd />);

    expect(wrapper).toMatchSnapshot();
  });
});
