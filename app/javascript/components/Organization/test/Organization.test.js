import React from 'react';
import { render } from '@testing-library/react'
import { ReposContext } from "../../../providers/ReposProvider";
import Organization from "../Organization";

describe('Organization', () => {
  it("renders an organization component", () => {
    const org = {
      id: 1,
      name: "Test org",
      config_enabled: true,
      config_repo: 'test/foo',
    };
    const repos = [{ id: 123, name: 'foo/bar', owner: { id: 1 } }];

    const { asFragment } = render(
      <ReposContext.Provider value={{ repos: repos }}>
        <Organization org={org} />
      </ReposContext.Provider>
    );

    expect(asFragment).toMatchSnapshot();
  });
});
