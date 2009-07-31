require File.dirname(__FILE__) + '/../lib/rencon.rb'

module Rencon

  describe Ticket do

    STATES = %w[
      number status project
      tracker priority subject
      assigned_to category
      target_version author
      start due_date done_rate
      estimated_time created_at
      updated_at description
    ]

    before do
      @states = STATES
      @values = STATES
      @issue = Ticket.new_with_order(@values, @states)
    end

    STATES.each do |state|
      it "has #{state}" do
        @issue.should respond_to(state)
        @issue.__send__(state).should == state
      end
    end

    it 'cannot call new' do
      lambda { Ticket.new }.should raise_error(NoMethodError)
    end
  end
end

