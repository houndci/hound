import ReposContainer from '../repos_container.js';
import * as Ajax from '../../lib/ajax.js';

it('renders appropriately', () => {
  const wrapper = shallow(
    <ReposContainer
      authenticity_token={"csrf_token"}
      has_private_access={false}
      userHasCard={false}
    />
  );
  expect(wrapper).toMatchSnapshot();
});

it('sets the filterTerm appropriately on text input', () => {
  const wrapper = mount(
    <ReposContainer
      authenticity_token={"csrf_token"}
      has_private_access={false}
      userHasCard={false}
    />
  );
  const textInput = wrapper.find('.repo-search-tools-input');
  textInput.simulate('change', {target: {value: "new text"}});

  expect(wrapper.state('filterTerm')).toBe('new text');
});

it('fetches repos and organizations on mount', () => {
  let stub = sinon.stub(ReposContainer.prototype, 'fetchReposAndOrgs');

  const wrapper = mount(
    <ReposContainer
      authenticity_token={"csrf_token"}
      has_private_access={false}
      userHasCard={false}
    />
  );

  expect(stub.callCount).toBe(1);
  stub.restore();
});

// it('tracks public repo activations', () => {
//   let spy = sinon.spy(ReposContainer.prototype, 'trackRepoActivated');

//   const activateRepoStub = sinon.stub(Ajax, 'activateRepo').returns(new $.Deferred());
//   const fetchReposStub = sinon.stub($, 'ajax').yieldsTo("success", [
//     {
//       "admin": true,
//       "active": false,
//       "name": "test/repo",
//       "full_plan_name": "Public Repo",
//       "github_id": 39266636,
//       "id": 342172,
//       "in_organization": true,
//       "owner": {
//           "id": 12109,
//           "github_id": 17184073,
//           "name": "test",
//           "organization": true,
//       },
//       "price_in_cents": 0,
//       "price_in_dollars": 0,
//       "private": false,
//       "stripe_subscription_id": null
//     }
//   ]);

//   const wrapper = mount(
//     <ReposContainer
//       authenticity_token={"csrf_token"}
//       has_private_access={false}
//       userHasCard={false}
//     />
//   );

//   wrapper.find(".repo-toggle").simulate('click');

//   expect(spy.calledOnce).toBe(true);

//   fetchReposStub.restore();
//   activateRepoStub.restore();
// });
