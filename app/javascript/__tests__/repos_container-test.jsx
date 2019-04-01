import ReposContainer from '../components/ReposContainer/components/App';
import * as Ajax from '../modules/Ajax';

describe('Repos Container component', () => {
  it('renders appropriately', () => {
    const wrapper = shallow(<ReposContainer />);

    expect(wrapper).toMatchSnapshot();
  });

  it('sets the filterTerm appropriately on text input', () => {
    const wrapper = mount(<ReposContainer />);
    wrapper.setState({ repos: [{ id: 1, name: 'foo/bar' }] });
    const textInput = wrapper.find('.repo-search-tools-input');

    textInput.simulate('change', {target: {value: "new text"}});

    expect(wrapper.state('filterTerm')).toBe('new text');
  });

  it('fetches repos on mount', () => {
    const spy = jest.spyOn(ReposContainer.prototype, 'fetchRepos');

    const wrapper = shallow(<ReposContainer />);

    expect(spy).toHaveBeenCalled()
  });
});
