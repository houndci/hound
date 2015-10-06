require 'spec_helper'

module Segment
  class Analytics
    describe Analytics do
      let(:analytics) { Segment::Analytics.new :write_key => WRITE_KEY, :stub => true }

      describe '#track' do
        it 'should error without an event' do
          expect { analytics.track(:user_id => 'user') }.to raise_error(ArgumentError)
        end

        it 'should error without a user_id' do
          expect { analytics.track(:event => 'Event') }.to raise_error(ArgumentError)
        end

        it 'should not error with the required options' do
          analytics.track Queued::TRACK
          sleep(1)
        end
      end


      describe '#identify' do
        it 'should error without a user_id' do
          expect { analytics.identify :traits => {} }.to raise_error(ArgumentError)
        end

        it 'should not error with the required options' do
          analytics.identify Queued::IDENTIFY
          sleep(1)
        end
      end

      describe '#alias' do
        it 'should error without from' do
          expect { analytics.alias :user_id => 1234 }.to raise_error(ArgumentError)
        end

        it 'should error without to' do
          expect { analytics.alias :previous_id => 1234 }.to raise_error(ArgumentError)
        end

        it 'should not error with the required options' do
          analytics.alias ALIAS
          sleep(1)
        end
      end

      describe '#group' do
        it 'should error without group_id' do
          expect { analytics.group :user_id => 'foo' }.to raise_error(ArgumentError)
        end

        it 'should error without user_id or anonymous_id' do
          expect { analytics.group :group_id => 'foo' }.to raise_error(ArgumentError)
        end

        it 'should not error with the required options' do
          analytics.group Queued::GROUP
          sleep(1)
        end
      end

      describe '#page' do
        it 'should error without user_id or anonymous_id' do
          expect { analytics.page :name => 'foo' }.to raise_error(ArgumentError)
        end

        it 'should not error with the required options' do
          analytics.page Queued::PAGE
          sleep(1)
        end
      end

      describe '#screen' do
        it 'should error without user_id or anonymous_id' do
          expect { analytics.screen :name => 'foo' }.to raise_error(ArgumentError)
        end

        it 'should not error with the required options' do
          analytics.screen Queued::SCREEN
          sleep(1)
        end
      end

      describe '#flush' do
        it 'should flush without error' do
          analytics.identify Queued::IDENTIFY
          analytics.flush
        end
      end
    end
  end
end
