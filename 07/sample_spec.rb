describe LazyMode do

  describe LazyMode::ScheduleNote do
    describe '#initialize' do

      it 'makes right interval 2 weeks' do
        sch = LazyMode::ScheduleNote.new("0-0-0", "+2w")
        expect(sch.interval).to eq LazyMode::Date.new("0-0-14")
      end

      it 'makes right interval 5 weeks' do
        sch = LazyMode::ScheduleNote.new("0-0-0", "+5w")
        expect(sch.interval).to eq LazyMode::Date.new("0-1-5")
      end

      it 'makes gives the right next +1 week' do
        sch = LazyMode::ScheduleNote.new('2012-08-06', "+1w")
        expect(sch.next).to eq LazyMode::Date.new('2012-08-13')
      end

      it 'makes gives the right next +1 month' do
        sch = LazyMode::ScheduleNote.new('2012-08-06', "+1m")
        expect(sch.next).to eq LazyMode::Date.new('2012-09-06')
      end
    end

  end
  describe LazyMode::Date do
    subject { LazyMode::Date.new('2012-08-07') }
    it { is_expected.to respond_to(:year) }
    it { is_expected.to respond_to(:month) }
    it { is_expected.to respond_to(:day) }

    describe "#initialize" do
      it 'checks date' do
        expect(LazyMode::Date.new('2012-12-30').year).to eq 2012
        expect(LazyMode::Date.new('2012-12-30').month).to eq 12
        expect(LazyMode::Date.new('2012-12-30').day).to eq 30

      end

    end

    describe '#+' do
      it 'sums zero dates' do
        new_date = LazyMode::Date.new('2012-12-30') + LazyMode::Date.new('0-0-1')
        expect(new_date.year).to eq 2013
        expect(new_date.month).to eq 1
        expect(new_date.day).to eq 1
      end

      it 'sums overflow month dates' do
        new_date = LazyMode::Date.new('2012-11-30') + LazyMode::Date.new('0-0-1')
        expect(new_date.year).to eq 2012
        expect(new_date.month).to eq 12
        expect(new_date.day).to eq 1
      end

      it 'sums dates' do
        new_date = LazyMode::Date.new('2012-11-29') + LazyMode::Date.new('0-0-1')
        expect(new_date.year).to eq 2012
        expect(new_date.month).to eq 11
        expect(new_date.day).to eq 30
      end
    end

    describe '#to_s' do
      it 'print dates' do
        new_date = LazyMode::Date.new('1-1-1')
        expect(new_date.to_s).to eq "0001-01-01"
      end
    end
  end

  describe '#body' do
    it 'sets body when not nil and returns it when nil' do
      note = LazyMode::Note.new('blaa', :haha)
      expect(note.body).to eq ''
      note.body "aaa"
      expect(note.body).to eq 'aaa'
    end
  end

  describe '#create_file' do

    it 'makes a note without schedule' do
      file = LazyMode.create_file('work') do
        note 'sleep', :important, :wip do
          status :postponed
          body 'Try sleeping more at work'
        end


        note 'useless activity' do
          scheduled '2012-08-07'
        end
      end

      expect(file.notes.size).to eq 2
      expect(file.daily_agenda(LazyMode::Date.new('2012-08-07')).notes.size).to eq 1
      expect(file.daily_agenda(LazyMode::Date.new('2012-08-06')).notes.size).to eq 0


    end

    it 'note without tags' do
      file = LazyMode.create_file('work') do
        note 'sleep' do
          status :postponed
          body 'Try sleeping more at work'
        end


        note 'useless activity' do
          scheduled '2012-08-07'
        end
      end

      expect(file.notes.size).to eq 2
      expect(file.daily_agenda(LazyMode::Date.new('2012-08-07')).notes.size).to eq 1
      expect(file.daily_agenda(LazyMode::Date.new('2012-08-06')).notes.size).to eq 0
    end

    it 'no note' do
      file = LazyMode.create_file('work') do
        p 'hey'
      end

      expect(file.notes.size).to eq 0

    end


    it 'handles unnested notes' do
      file = LazyMode.create_file('work') do
        note 'sleep', :important, :wip do
          scheduled '2012-08-07'
          status :postponed
          body 'Try sleeping more at work'
        end


        note 'useless activity' do
          scheduled '2012-08-07'
        end
      end



      expect(file.notes.size).to eq 2

      first_note = file.notes.find { |note| note.header == 'sleep' }
      expect(first_note.file_name).to eq('work')
      expect(first_note.header).to eq('sleep')
      expect(first_note.tags).to eq([:important, :wip])
      expect(first_note.status).to eq(:postponed)
      expect(first_note.body).to eq('Try sleeping more at work')

      second_note = file.notes.find { |note| note.header == 'useless activity' }
      expect(second_note.file_name).to eq('work')
      expect(second_note.header).to eq('useless activity')
      expect(second_note.tags).to eq([])
      expect(second_note.status).to eq(:topostpone)
    end

    it 'handles nested notes' do
      file = LazyMode.create_file('work') do
        note 'sleep', :important, :wip do
          scheduled '2012-08-07'
          status :postponed
          body 'Try sleeping more at work'
          note 'useless activity' do
            scheduled '2012-08-07'
            note 'useless activity' do
              scheduled '2012-08-07'
              note 'useless activity' do
                scheduled '2012-08-07'
                note 'useless activity' do
                  scheduled '2012-08-07'
                end
              end
            end
          end
        end
      end



      expect(file.notes.size).to eq 5
      #notes = file.notes.map{ |x| x.header}
      #p notes
      #еxpect(file.notes).to eq ['sleep', 'useless activity','useless activity','useless activity','useless activity']
    end
  end

  describe '#daily_agenda' do
    it 'returns all notes for a given day' do
      file = LazyMode.create_file('nesting') do
        note 'task' do
          scheduled '2012-08-07'

          note 'subtask' do
            scheduled '2012-08-06 +1w'
          end
        end
      end

      daily_agenda = file.daily_agenda(LazyMode::Date.new('2012-08-13'))
      expect(daily_agenda.notes.size).to eq(1)
      expect(daily_agenda.notes.first.header).to eq('subtask')
      expect(daily_agenda.notes.first.date.to_s).to eq('2012-08-13')
    end
  end


  describe '#daily_agenda' do
    it 'returns all notes for a given week' do
      file = LazyMode.create_file('week') do
        note 'task' do
          scheduled '2012-08-07'

          note 'subtask' do
            scheduled '2012-08-06'
          end

          note 'subtask 2' do
            scheduled '2012-08-05'
          end
        end
      end

      weekly_agenda = file.weekly_agenda(LazyMode::Date.new('2012-08-06'))
      expect(weekly_agenda.notes.size).to eq(2)            #=> 2
      task_note = weekly_agenda.notes.find { |note| note.header == 'task' }
      expect(task_note.date.to_s).to eq('2012-08-07')
      subtask_note = weekly_agenda.notes.find { |note| note.header == 'subtask' }
      expect(subtask_note.date.to_s).to eq('2012-08-06')
    end

    describe '#where' do
      before(:each) do
        @file = LazyMode.create_file('week with tags') do
          note 'task', :important do
            scheduled '2012-08-07'

            note 'subtask' do
              scheduled '2012-08-06'
            end

            note 'subtask 2', :important do
              scheduled '2012-08-05'
            end
          end
        end
      end

      it 'filters by tag' do
        weekly_agenda = @file.weekly_agenda(LazyMode::Date.new('2012-08-05'))
        important_tasks = weekly_agenda.where(tag: :important)
        expect(important_tasks.notes.size).to eq(2)
        expect(important_tasks.notes.find { |note| note.header == 'task' }).not_to be_nil
        expect(important_tasks.notes.find { |note| note.header == 'subtask 2' }).not_to be_nil
      end

      it 'filters by tag and text' do
        weekly_agenda = @file.weekly_agenda(LazyMode::Date.new('2012-08-05'))
        important_subtasks = weekly_agenda.where(tag: :important, text: /sub/)
        expect(important_subtasks.notes.size).to eq(1)
        expect(important_subtasks.notes.first.header).to eq('subtask 2')
      end

      it 'filters no match' do
        weekly_agenda = @file.weekly_agenda(LazyMode::Date.new('2012-08-05'))
        important_subtasks = weekly_agenda.where(tag: :important, text: /aaa/)
        expect(important_subtasks.notes.size).to eq(0)
      end
    end
  end
end
