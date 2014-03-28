require 'spec_helper'

describe SessionsController, '#new' do
  context 'when https is enabled' do
    context 'and http is used' do
      it 'redirects to https' do
        ENV['ENABLE_HTTPS'] = 'yes'

        get :new

        expect(response).to redirect_to(sign_in_url(protocol: 'https'))
      end
    end

    context 'and https is used' do
      it 'does not redirect' do
        ENV['ENABLE_HTTPS'] = 'yes'
        request.env['HTTPS'] = 'on'

        get :new

        expect(response).not_to be_redirect
      end
    end
  end

  context 'when https is disabled' do
    context 'and http is used' do
      it 'does not redirect' do
        ENV['ENABLE_HTTPS'] = 'no'

        get :new

        expect(response).not_to be_redirect
      end
    end
  end
end
