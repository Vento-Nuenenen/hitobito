# frozen_string_literal: true

#  Copyright (c) 2024, Schweizer Alpen-Club. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe Person::Subscriptions do
  include Subscriptions::SpecHelper

  let(:list)      { mailing_lists(:leaders) }
  let(:person)    { people(:top_leader) }
  let(:group)     { groups(:top_group) }

  # let(:top_layer) { groups(:top_layer) }

  context 'subscribable_for anyone' do
    before { list.update(subscribable_for: :anyone) }

    describe '#subscribed' do
      subject(:subscribed) { described_class.new(person).subscribed }

      it 'is empty without subscription' do
        expect(subscribed).to be_empty
      end

      it 'includes list when direct subscription exists' do
        create_person_subscription
        expect(subscribed).to eq [list]
      end

      it 'includes list when group subscription exists' do
        create_group_subscription
        expect(subscribed).to eq [list]
      end

      it 'includes list when event subscription exists' do
        create_event_subscription
        expect(subscribed).to eq [list]
      end

      it 'excludes list when group subscriptions exists but excluded' do
        create_group_subscription
        create_person_subscription(excluded: true)
        expect(subscribed).to be_empty
      end

      it 'excludes list when event subscriptions exists but excluded' do
        create_event_subscription
        create_person_subscription(excluded: true)
        expect(subscribed).to be_empty
      end
    end

    describe '#subscribable' do
      subject(:subscribable) { described_class.new(person).subscribable }
      before { MailingList.where.not(id: list.id).destroy_all }

      it 'includes list when no subscription exists' do
        expect(subscribable).to eq [list]
      end

      it 'excludes list when direct subscription exists' do
        create_person_subscription
        expect(subscribable).to be_empty
      end

      it 'excludes list when group subscription exists' do
        create_group_subscription
        expect(subscribable).to be_empty
      end

      it 'excludes list when event subscription exists' do
        create_event_subscription
        expect(subscribable).to be_empty
      end

      it 'includes list when group subscriptions exists but excluded' do
        create_group_subscription
        create_person_subscription(excluded: true)
        expect(subscribable).to eq [list]
      end

      it 'includes list when event subscriptions exists but excluded' do
        create_event_subscription
        create_person_subscription(excluded: true)
        expect(subscribable).to eq [list]
      end
    end
  end

  context 'subscribable_for configured with mode opt_out' do
    before { list.update(subscribable_for: :configured, subscribable_mode: :opt_out) }

    describe '#subscribed' do
      subject(:subscribed) { described_class.new(person).subscribed }

      it 'is empty without subscription' do
        expect(subscribed).to be_empty
      end

      it 'includes list when direct subscription exists' do
        create_person_subscription
        expect(subscribed).to eq [list]
      end

      it 'includes list when group subscription exists' do
        create_group_subscription
        expect(subscribed).to eq [list]
      end

      it 'includes list when event subscription exists' do
        create_event_subscription
        expect(subscribed).to eq [list]
      end

      it 'excludes list when group subscriptions exists but excluded' do
        create_group_subscription
        create_person_subscription(excluded: true)
        expect(subscribed).to be_empty
      end

      it 'excludes list when event subscriptions exists but excluded' do
        create_event_subscription
        create_person_subscription(excluded: true)
        expect(subscribed).to be_empty
      end
    end

    describe '#subscribable' do
      subject(:subscribable) { described_class.new(person).subscribable }
      before { MailingList.where.not(id: list.id).destroy_all }

      it 'excludes list when no subscription exists' do
        expect(subscribable).to be_empty
      end

      it 'excludes list when direct subscription exists' do
        create_person_subscription
        expect(subscribable).to be_empty
      end

      it 'excludes list when group subscription exists' do
        create_group_subscription
        expect(subscribable).to be_empty
      end

      it 'excludes list when event subscription exists' do
        create_event_subscription
        expect(subscribable).to be_empty
      end

      it 'includes list when group subscriptions exists but excluded' do
        create_group_subscription
        create_person_subscription(excluded: true)
        expect(subscribable).to eq [list]
      end

      it 'includes list when event subscriptions exists but excluded' do
        create_event_subscription
        create_person_subscription(excluded: true)
        expect(subscribable).to eq [list]
      end
    end
  end

  context 'subscribable_for configured with mode opt_in' do
    before { list.update(subscribable_for: :configured, subscribable_mode: :opt_in) }

    describe '#subscribed' do
      subject(:subscribed) { described_class.new(person).subscribed }

      it 'is empty without subscription' do
        expect(subscribed).to be_empty
      end

      it 'includes list when direct subscription exists' do
        create_person_subscription
        expect(subscribed).to eq [list]
      end

      it 'excludes list when group subscription exists' do
        create_group_subscription
        expect(subscribed).to be_empty
      end

      it 'excludes list when event subscription exists' do
        create_event_subscription
        expect(subscribed).to be_empty
      end

      it 'excludes list when group subscriptions exists but excluded' do
        create_group_subscription
        create_person_subscription(excluded: true)
        expect(subscribed).to be_empty
      end

      it 'excludes list when event subscriptions exists but excluded' do
        create_event_subscription
        create_person_subscription(excluded: true)
        expect(subscribed).to be_empty
      end
    end

    describe '#subscribable' do
      subject(:subscribable) { described_class.new(person).subscribable }
      before { MailingList.where.not(id: list.id).destroy_all }

      it 'excludes list when no subscription exists' do
        expect(subscribable).to be_empty
      end

      it 'excludes list when direct subscription exists' do
        create_person_subscription
        expect(subscribable).to be_empty
      end

      it 'includes list when group subscription exists' do
        create_group_subscription
        expect(subscribable).to eq [list]
      end

      it 'includes list when event subscription exists' do
        create_event_subscription
        expect(subscribable).to eq [list]
      end

      it 'includes list when group subscriptions exists but excluded' do
        create_group_subscription
        create_person_subscription(excluded: true)
        expect(subscribable).to eq [list]
      end

      it 'includes list when event subscriptions exists but excluded' do
        create_event_subscription
        create_person_subscription(excluded: true)
        expect(subscribable).to eq [list]
      end
    end
  end

  context :mailing_lists do
    subject { Person::Subscriptions.new(person).subscribed }
    let(:top_layer) { groups(:top_layer) }
    let(:top_group) { groups(:top_group) }

    let!(:direct) do
      Fabricate(:mailing_list, subscribable_for: :anyone, group: top_layer).tap do |list|
        create_person_subscription(mailing_list: list)
      end
    end

    let!(:from_event) do
      Fabricate(:mailing_list, subscribable_for: :anyone, group: top_layer).tap do |list|
        create_event_subscription(mailing_list: list, groups: [top_layer])
      end
    end

    let!(:from_group) do
      Fabricate(:mailing_list, subscribable_for: :anyone, group: top_layer).tap do |list|
        create_group_subscription(mailing_list: list, subscriber: top_group)
        # list.subscriptions.create!(subscriber: top_group, role_types: ['Group::TopGroup::Leader'])
      end
    end

    it 'includes all three mailing lists' do
      expect(subject).to match_array [direct, from_event, from_group]
    end

    it 'does not include group if person is excluded' do
      create_person_subscription(mailing_list: from_group, excluded: true)
      expect(subject).to match_array [direct, from_event]
    end
  end

  describe 'event participation active state'  do
    let(:person)        { people(:bottom_member) }
    let(:event)         { events(:top_course) }
    let(:participation) { event_participations(:top) }

    subject { Person::Subscriptions.new(person).subscribed }

    before do
      event.dates.first.update(start_at: 10.days.ago)
      list.subscriptions.create(subscriber: event)
    end

    it 'includes subscription for active participation' do
      expect(subject).to be_present
    end

    it 'does not include subscription for passive participation' do
      participation.update!(active: false)
      expect(subject).to be_empty
    end
  end

  context :from_groups do
    let(:top_layer)    { groups(:top_layer) }
    let(:person)       { people(:bottom_member) }
    let(:subscription) { subscriptions(:list_group) }

    let(:bottom_layer_one) { groups(:bottom_layer_one) }
    let(:bottom_layer_two) { groups(:bottom_layer_two) }

    subject { Person::Subscriptions.new(person).subscribed }

    it 'is present when created for group' do
      list.subscriptions.create!(subscriber: bottom_layer_one,
                                    role_types: ['Group::BottomLayer::Member'])
      expect(subject).to have(1).item
    end

    it 'is present when created for ancestor group' do
      list.subscriptions.create!(subscriber: top_layer,
                                    role_types: ['Group::BottomLayer::Member'])
      expect(subject).to have(1).item
    end

    it 'is empty when created for sibling group' do
      list.subscriptions.create!(subscriber: bottom_layer_two,
                                    role_types: ['Group::BottomLayer::Member'])
      expect(subject).to be_empty
    end

    it 'is empty when tag required' do
      subscription_tag = SubscriptionTag.new(tag: ActsAsTaggableOn::Tag.create!(name: 'foo'))
      list.subscriptions.create!(subscriber: bottom_layer_one,
                                    role_types: ['Group::BottomLayer::Member'], subscription_tags: [subscription_tag])
      expect(subject).to be_empty
    end

    it 'is present when tag is required and any person matches and tag does not exclude' do
      subscription_tag = SubscriptionTag.new(tag: ActsAsTaggableOn::Tag.create!(name: 'foo'),
                                             excluded: false)
      list.subscriptions.create!(subscriber: bottom_layer_one,
                                    role_types: ['Group::BottomLayer::Member'], subscription_tags: [subscription_tag])
      person.update!(tag_list: %w(foo buz))
      expect(subject).to have(1).item
    end

    it 'is empty when tag is required and any person matches and tag does exclude' do
      subscription_tag = SubscriptionTag.new(tag: ActsAsTaggableOn::Tag.create!(name: 'foo'),
                                             excluded: true)
      subscription_tag2 = SubscriptionTag.new(tag: ActsAsTaggableOn::Tag.create!(name: 'bar'),
                                              excluded: false)
      list.subscriptions.create!(subscriber: bottom_layer_one,
                                    role_types: ['Group::BottomLayer::Member'], subscription_tags: [subscription_tag, subscription_tag2])
      person.update!(tag_list: %w(foo bar))
      expect(subject).to be_empty
    end

    it 'is empty when the person has no roles' do
      list.subscriptions.create!(subscriber: bottom_layer_one,
                                    role_types: ['Group::BottomLayer::Member'])
      person.roles.destroy_all
      expect(subject).to be_empty
    end
  end
end
