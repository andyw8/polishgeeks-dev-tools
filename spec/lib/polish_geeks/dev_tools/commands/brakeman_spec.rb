require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::Brakeman do
  context 'class' do
    subject { described_class }

    describe '#validators' do
      it 'works only when we have Rails framework' do
        expect(subject.validators).to eq [PolishGeeks::DevTools::Validators::Rails]
      end
    end
  end

  context 'instance' do
    subject { described_class.new }

    describe '#execute' do
      context 'when we run brakeman' do
        let(:instance) { instance_double(PolishGeeks::DevTools::Shell) }

        before do
          allow(PolishGeeks::DevTools::Shell).to receive(:new) { instance }
          expect(instance).to receive(:execute).with('bundle exec brakeman -q')
        end

        it 'executes the command' do
          subject.execute
        end
      end
    end

    describe '#valid?' do
      context 'when warnings are equal 0' do
        before do
          expect(subject)
            .to receive(:warnings)
            .and_return(0)
        end

        context 'and errors are equal 0' do
          before do
            expect(subject)
              .to receive(:errors)
              .and_return(0)
          end

          it 'returns true' do
            expect(subject.valid?).to eq true
          end
        end

        context 'and errors are not equal 0' do
          before do
            expect(subject)
              .to receive(:errors)
              .and_return(1)
          end

          it 'returns true' do
            expect(subject.valid?).to eq false
          end
        end
      end
    end

    describe 'label' do
      let(:models) { rand(1000) }
      let(:controllers) { rand(1000) }
      let(:templates) { rand(1000) }

      before do
        expect(subject).to receive(:models).and_return(models)
        expect(subject).to receive(:controllers).and_return(controllers)
        expect(subject).to receive(:templates).and_return(templates)
      end

      it 'uses details' do
        label = "Brakeman (#{controllers} con, #{models} mod, #{templates} temp)"
        expect(subject.label).to eq label
      end
    end

    describe 'counter' do
      described_class::REGEXPS.each do |name, _regexp|
        describe "##{name}" do
          let(:amount) { rand(1000) }

          before do
            subject.instance_variable_set(:@output, "#{name.to_s.capitalize} #{amount}")
          end

          it 'returns a proper value' do
            expect(subject.send(name)).to eq amount
          end
        end
      end
    end
  end
end
