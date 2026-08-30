require 'rails_helper'

RSpec.describe Video, type: :model do
  describe 'associations' do
    it { should belong_to(:videoable) }
  end

  describe 'validations' do
    it { should validate_presence_of(:url) }

    describe 'url format validation' do
      it 'accepts valid http URLs' do
        video = build(:video, url: 'http://example.com/video')
        expect(video).to be_valid
      end

      it 'accepts valid https URLs' do
        video = build(:video, url: 'https://example.com/video')
        expect(video).to be_valid
      end

      it 'accepts valid YouTube URLs' do
        video = build(:video, url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ')
        expect(video).to be_valid
      end

      it 'rejects invalid URLs' do
        video = build(:video, url: 'not-a-url')
        expect(video).not_to be_valid
      end

      it 'rejects URLs without protocol' do
        video = build(:video, url: 'example.com')
        expect(video).not_to be_valid
      end
    end
  end

  describe 'derived attributes' do
    describe '#exercise_title' do
      it 'returns the name of the associated exercise' do
        exercise = create(:strength_exercise, name: 'Supino Reto')
        video = create(:video, videoable: exercise)
        expect(video.exercise_title).to eq('Supino Reto')
      end

      it 'returns nil when there is no associated record' do
        expect(Video.new.exercise_title).to be_nil
      end
    end

    describe '#exercise_category' do
      it 'returns the default category' do
        expect(build(:video).exercise_category).to eq('Técnica')
      end
    end
  end

  describe 'callbacks' do
    describe 'before_save :extract_youtube_thumbnail' do
      context 'with YouTube URL' do
        it 'extracts thumbnail for standard YouTube URL' do
          video = create(:video, url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ')
          expect(video.thumbnail_url).to eq('https://img.youtube.com/vi/dQw4w9WgXcQ/mqdefault.jpg')
        end

        it 'extracts thumbnail for short YouTube URL' do
          video = create(:video, url: 'https://youtu.be/dQw4w9WgXcQ')
          expect(video.thumbnail_url).to eq('https://img.youtube.com/vi/dQw4w9WgXcQ/mqdefault.jpg')
        end

        it 'handles URL with additional parameters' do
          video = create(:video, url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ&feature=share')
          expect(video.thumbnail_url).to eq('https://img.youtube.com/vi/dQw4w9WgXcQ/mqdefault.jpg')
        end
      end

      context 'with non-YouTube URL' do
        it 'does not set thumbnail_url' do
          video = create(:video, url: 'https://vimeo.com/123456')
          expect(video.thumbnail_url).to be_nil
        end
      end

      context 'when URL changes' do
        it 'updates thumbnail_url' do
          video = create(:video, url: 'https://www.youtube.com/watch?v=video1')
          expect(video.thumbnail_url).to eq('https://img.youtube.com/vi/video1/mqdefault.jpg')

          video.update(url: 'https://www.youtube.com/watch?v=video2')
          expect(video.thumbnail_url).to eq('https://img.youtube.com/vi/video2/mqdefault.jpg')
        end
      end

      context 'when URL does not change' do
        it 'does not re-extract thumbnail' do
          video = create(:video, url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ')
          original_thumbnail = video.thumbnail_url

          video.update(description: 'New Description')
          expect(video.thumbnail_url).to eq(original_thumbnail)
        end
      end
    end
  end

  describe '#youtube_video_id' do
    context 'with standard YouTube URL' do
      it 'extracts video ID' do
        video = build(:video, url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ')
        expect(video.youtube_video_id).to eq('dQw4w9WgXcQ')
      end
    end

    context 'with short YouTube URL' do
      it 'extracts video ID' do
        video = build(:video, url: 'https://youtu.be/dQw4w9WgXcQ')
        expect(video.youtube_video_id).to eq('dQw4w9WgXcQ')
      end
    end

    context 'with YouTube URL with parameters' do
      it 'extracts video ID' do
        video = build(:video, url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=30s')
        expect(video.youtube_video_id).to eq('dQw4w9WgXcQ')
      end
    end

    context 'with non-YouTube URL' do
      it 'returns nil' do
        video = build(:video, url: 'https://vimeo.com/123456')
        expect(video.youtube_video_id).to be_nil
      end
    end

    context 'with nil URL' do
      it 'returns nil' do
        video = Video.new(url: nil)
        expect(video.youtube_video_id).to be_nil
      end
    end
  end

  describe '#safe_url' do
    context 'with valid https URL' do
      it 'returns the URL' do
        video = build(:video, url: 'https://www.youtube.com/watch?v=abc123')
        expect(video.safe_url).to eq('https://www.youtube.com/watch?v=abc123')
      end
    end

    context 'with valid http URL' do
      it 'returns the URL' do
        video = build(:video, url: 'http://example.com/video.mp4')
        expect(video.safe_url).to eq('http://example.com/video.mp4')
      end
    end

    context 'with malformed URL' do
      it 'returns nil' do
        video = Video.new(url: 'javascript:alert(1)')
        video.valid? # trigger validators
        expect(video.safe_url).to be_nil
      end
    end

    context 'with nil URL' do
      it 'returns nil' do
        video = Video.new(url: nil)
        expect(video.safe_url).to be_nil
      end
    end

    context 'with ftp URL' do
      it 'returns nil for non-http/https schemes' do
        video = Video.new(url: 'ftp://example.com/file')
        expect(video.safe_url).to be_nil
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:video)).to be_valid
    end

    it 'creates a video with all required attributes' do
      video = create(:video)
      expect(video.url).to be_present
      expect(video.videoable).to be_present
      expect(video.exercise_title).to be_present
      expect(video.exercise_category).to be_present
    end

    describe 'traits' do
      it 'creates video for strength exercise' do
        video = create(:video, :for_strength)
        expect(video.videoable).to be_a(StrengthExercise)
      end

      it 'creates video for cardio exercise' do
        video = create(:video, :for_cardio)
        expect(video.videoable).to be_a(CardioExercise)
      end

      it 'creates video for core exercise' do
        video = create(:video, :for_core)
        expect(video.videoable).to be_a(CoreExercise)
      end

      it 'creates video for mobility exercise' do
        video = create(:video, :for_mobility)
        expect(video.videoable).to be_a(MobilityExercise)
      end
    end
  end

  describe 'polymorphic association' do
    it 'can belong to different exercise types' do
      strength_video = create(:video, :for_strength)
      cardio_video = create(:video, :for_cardio)

      expect(strength_video.videoable_type).to eq('StrengthExercise')
      expect(cardio_video.videoable_type).to eq('CardioExercise')
    end
  end
end
