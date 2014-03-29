require 'spec_helper'

describe SessionsController, '#new' do
  context 'when https is enabled' do
    context 'and http is used' do
      it 'redirects to https' do
        with_https_enabled do
          get :new

          expect(response).to redirect_to(sign_in_url(protocol: 'https'))
        end
      end
    end

    context 'and https is used' do
      it 'does not redirect' do
        with_https_enabled do
          request.env['HTTPS'] = 'on'

          get :new

          expect(response).not_to be_redirect
        end
      end
    end
  end

  context 'when https is disabled' do
    context 'and http is used' do
      it 'does not redirect' do
        get :new

        expect(response).not_to be_redirect
      end
    end
  end
end
