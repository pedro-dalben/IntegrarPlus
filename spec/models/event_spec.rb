# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:professional) { create(:professional) }
  let(:other_professional) { create(:professional) }

  describe 'associations' do
    it { should belong_to(:professional) }
    it { should belong_to(:created_by).class_name('Professional') }
  end

  describe 'enums' do
    it {
      should define_enum_for(:event_type).with_values(personal: 0, consulta: 1, atendimento: 2, reuniao: 3, outro: 4)
    }
    it {
      should define_enum_for(:visibility_level).with_values(personal_private: 0, restricted: 1, publicly_visible: 2)
    }
    it { should define_enum_for(:status).with_values(active: 0, cancelled: 1, completed: 2) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:start_time) }
    it { should validate_presence_of(:end_time) }
    it { should validate_presence_of(:event_type) }
    it { should validate_presence_of(:visibility_level) }
    it { should validate_presence_of(:professional_id) }
    it { should validate_presence_of(:created_by_id) }

    it { should validate_length_of(:title).is_at_most(255) }
  end

  describe 'custom validations' do
    let(:event) { build(:event, professional: professional, created_by: professional) }

    context 'when end_time is before start_time' do
      it 'is invalid' do
        event.start_time = 1.hour.from_now
        event.end_time = 30.minutes.from_now

        expect(event).not_to be_valid
        expect(event.errors[:end_time]).to include('deve ser posterior ao horário de início')
      end
    end

    context 'when end_time equals start_time' do
      it 'is invalid' do
        event.start_time = 1.hour.from_now
        event.end_time = 1.hour.from_now

        expect(event).not_to be_valid
        expect(event.errors[:end_time]).to include('deve ser posterior ao horário de início')
      end
    end

    context 'when end_time is after start_time' do
      it 'is valid' do
        event.start_time = 1.hour.from_now
        event.end_time = 2.hours.from_now

        expect(event).to be_valid
      end
    end
  end

  describe 'scopes' do
    let!(:event1) do
      create(:event, professional: professional, start_time: 1.hour.from_now, end_time: 2.hours.from_now)
    end
    let!(:event2) do
      create(:event, professional: professional, start_time: 3.hours.from_now, end_time: 4.hours.from_now)
    end
    let!(:event3) do
      create(:event, professional: professional, start_time: 5.hours.from_now, end_time: 6.hours.from_now)
    end

    describe '.for_professional' do
      it 'returns events for a specific professional' do
        other_event = create(:event, professional: other_professional)

        expect(Event.for_professional(professional.id)).to include(event1, event2, event3)
        expect(Event.for_professional(professional.id)).not_to include(other_event)
      end
    end

    describe '.in_time_range' do
      it 'returns events within a time range' do
        start_time = 2.hours.from_now
        end_time = 4.hours.from_now

        expect(Event.in_time_range(start_time, end_time)).to include(event2)
        expect(Event.in_time_range(start_time, end_time)).not_to include(event1, event3)
      end
    end

    describe '.active_events' do
      it 'returns only active events' do
        event1.update(status: :cancelled)

        expect(Event.active_events).to include(event2, event3)
        expect(Event.active_events).not_to include(event1)
      end
    end
  end

  describe 'instance methods' do
    let(:event) { create(:event, professional: professional, start_time: 1.hour.from_now, end_time: 2.hours.from_now) }

    describe '#duration_minutes' do
      it 'returns the duration in minutes' do
        expect(event.duration_minutes).to eq(60)
      end
    end

    describe '#conflicts_with?' do
      let(:conflicting_event) do
        create(:event, professional: professional, start_time: 1.hour.from_now + 30.minutes,
                       end_time: 2.hours.from_now + 30.minutes)
      end
      let(:non_conflicting_event) do
        create(:event, professional: professional, start_time: 3.hours.from_now, end_time: 4.hours.from_now)
      end

      it 'returns true for conflicting events' do
        expect(event.conflicts_with?(conflicting_event)).to be true
      end

      it 'returns false for non-conflicting events' do
        expect(event.conflicts_with?(non_conflicting_event)).to be false
      end

      it 'returns false when comparing with itself' do
        expect(event.conflicts_with?(event)).to be false
      end
    end

    describe '#visible_for_professional?' do
      context 'when professional is the owner' do
        it 'returns true' do
          expect(event.visible_for_professional?(professional)).to be true
        end
      end

      context 'when event is publicly_visible' do
        before { event.update(visibility_level: :publicly_visible) }

        it 'returns true for any professional' do
          expect(event.visible_for_professional?(other_professional)).to be true
        end
      end

      context 'when event is personal_private' do
        before { event.update(visibility_level: :personal_private) }

        it 'returns false for other professionals' do
          expect(event.visible_for_professional?(other_professional)).to be false
        end
      end
    end

    describe '#masked_for_institutional_view' do
      context 'when event is publicly_visible' do
        before { event.update(visibility_level: :publicly_visible) }

        it 'returns the original event' do
          masked = event.masked_for_institutional_view
          expect(masked.title).to eq(event.title)
          expect(masked.description).to eq(event.description)
        end
      end

      context 'when event is personal_private or restricted' do
        before { event.update(visibility_level: :personal_private) }

        it 'returns masked event' do
          masked = event.masked_for_institutional_view
          expect(masked.title).to eq('Ocupado')
          expect(masked.description).to be_nil
        end
      end
    end
  end

  describe 'class methods' do
    let!(:event1) do
      create(:event, professional: professional, start_time: 1.hour.from_now, end_time: 2.hours.from_now)
    end
    let!(:event2) do
      create(:event, professional: professional, start_time: 3.hours.from_now, end_time: 4.hours.from_now)
    end

    describe '.availability_for_professional' do
      it 'returns availability information' do
        start_time = 30.minutes.from_now
        end_time = 1.hour.from_now + 30.minutes

        result = Event.availability_for_professional(professional.id, start_time, end_time)

        expect(result[:professional_id]).to eq(professional.id)
        expect(result[:start_time]).to eq(start_time)
        expect(result[:end_time]).to eq(end_time)
        expect(result[:available]).to be false
        expect(result[:conflicting_events]).to include(event1)
      end
    end

    describe '.create_with_conflict_check' do
      context 'when there are no conflicts' do
        it 'creates the event successfully' do
          start_time = 5.hours.from_now
          end_time = 6.hours.from_now

          result = Event.create_with_conflict_check(
            professional: professional,
            created_by: professional,
            title: 'Test Event',
            start_time: start_time,
            end_time: end_time,
            event_type: :personal,
            visibility_level: :publicly_visible
          )

          expect(result[:success]).to be true
          expect(result[:event]).to be_persisted
        end
      end

      context 'when there are conflicts' do
        it 'returns error information' do
          start_time = 1.hour.from_now + 30.minutes
          end_time = 2.hours.from_now + 30.minutes

          result = Event.create_with_conflict_check(
            professional: professional,
            created_by: professional,
            title: 'Conflicting Event',
            start_time: start_time,
            end_time: end_time,
            event_type: :personal,
            visibility_level: :publicly_visible
          )

          expect(result[:success]).to be false
          expect(result[:errors]).to include('Horário conflita com eventos existentes')
          expect(result[:conflicts]).to include(event1)
        end
      end
    end
  end
end
