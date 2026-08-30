require 'rails_helper'

RSpec.describe IconHelper, type: :helper do
  describe '#icon' do
    # Dashboard tab icons
    context 'when name is training' do
      it 'renders training icon SVG' do
        result = helper.icon(:training)
        expect(result).to include('<svg')
        expect(result).to include('w-5 h-5')
        expect(result).to include('M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4')
      end
    end

    context 'when name is nutrition' do
      it 'renders nutrition icon SVG' do
        result = helper.icon(:nutrition)
        expect(result).to include('<svg')
        expect(result).to include('M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293')
      end
    end

    context 'when name is goals' do
      it 'renders goals icon SVG' do
        result = helper.icon(:goals)
        expect(result).to include('<svg')
        expect(result).to include('M9 12l2 2 4-4')
      end
    end

    context 'when name is evaluation' do
      it 'renders evaluation icon SVG' do
        result = helper.icon(:evaluation)
        expect(result).to include('<svg')
        expect(result).to include('M9 19v-6a2 2 0 00-2-2H5')
      end
    end

    context 'when name is shop' do
      it 'renders shop icon SVG' do
        result = helper.icon(:shop)
        expect(result).to include('<svg')
        expect(result).to include('M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z')
      end
    end

    context 'when name is logout' do
      it 'renders logout icon SVG' do
        result = helper.icon(:logout)
        expect(result).to include('<svg')
        expect(result).to include('M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6')
      end
    end

    # Common action icons
    context 'when name is check' do
      it 'renders check icon SVG' do
        result = helper.icon(:check)
        expect(result).to include('<svg')
        expect(result).to include('M5 13l4 4L19 7')
      end
    end

    context 'when name is x' do
      it 'renders x icon SVG' do
        result = helper.icon(:x)
        expect(result).to include('<svg')
        expect(result).to include('M6 18L18 6M6 6l12 12')
      end
    end

    context 'when name is edit' do
      it 'renders edit icon SVG' do
        result = helper.icon(:edit)
        expect(result).to include('<svg')
        expect(result).to include('M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11')
      end
    end

    context 'when name is trash' do
      it 'renders trash icon SVG' do
        result = helper.icon(:trash)
        expect(result).to include('<svg')
        expect(result).to include('M19 7l-.867 12.142A2 2 0 0116.138 21H7.862')
      end
    end

    context 'when name is plus' do
      it 'renders plus icon SVG' do
        result = helper.icon(:plus)
        expect(result).to include('<svg')
        expect(result).to include('M12 4v16m8-8H4')
      end
    end

    context 'when name is minus' do
      it 'renders minus icon SVG' do
        result = helper.icon(:minus)
        expect(result).to include('<svg')
        expect(result).to include('M20 12H4')
      end
    end

    # Info icons
    context 'when name is info' do
      it 'renders info icon SVG' do
        result = helper.icon(:info)
        expect(result).to include('<svg')
        expect(result).to include('M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0')
      end
    end

    context 'when name is warning' do
      it 'renders warning icon SVG' do
        result = helper.icon(:warning)
        expect(result).to include('<svg')
        expect(result).to include('M12 9v2m0 4h.01m-6.938 4h13.856')
      end
    end

    # Status icons
    context 'when name is clock' do
      it 'renders clock icon SVG' do
        result = helper.icon(:clock)
        expect(result).to include('<svg')
        expect(result).to include('M12 8v4l3 3m6-3a9 9 0 11-18 0')
      end
    end

    context 'when name is calendar' do
      it 'renders calendar icon SVG' do
        result = helper.icon(:calendar)
        expect(result).to include('<svg')
        expect(result).to include('M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7')
      end
    end

    # Arrow icons
    context 'when name is arrow_right' do
      it 'renders arrow right icon SVG' do
        result = helper.icon(:arrow_right)
        expect(result).to include('<svg')
        expect(result).to include('M9 5l7 7-7 7')
      end
    end

    context 'when name is arrow_left' do
      it 'renders arrow left icon SVG' do
        result = helper.icon(:arrow_left)
        expect(result).to include('<svg')
        expect(result).to include('M15 19l-7-7 7-7')
      end
    end

    context 'when name is chevron_down' do
      it 'renders chevron down icon SVG' do
        result = helper.icon(:chevron_down)
        expect(result).to include('<svg')
        expect(result).to include('M19 9l-7 7-7-7')
      end
    end

    context 'when name is chevron_up' do
      it 'renders chevron up icon SVG' do
        result = helper.icon(:chevron_up)
        expect(result).to include('<svg')
        expect(result).to include('M5 15l7-7 7 7')
      end
    end

    # Edge cases
    context 'when name is unknown' do
      it 'returns empty string' do
        result = helper.icon(:unknown_icon)
        expect(result).to eq('')
      end
    end

    context 'when name is nil' do
      it 'raises an error' do
        expect { helper.icon(nil) }.to raise_error(NoMethodError)
      end
    end

    context 'when name is string instead of symbol' do
      it 'converts to symbol and renders icon' do
        result = helper.icon('check')
        expect(result).to include('<svg')
        expect(result).to include('M5 13l4 4L19 7')
      end
    end

    # Size parameter tests
    context 'with default size' do
      it 'uses w-5 h-5 size class' do
        result = helper.icon(:check)
        expect(result).to include('w-5 h-5')
      end
    end

    context 'with custom size' do
      it 'uses custom size class' do
        result = helper.icon(:check, size: 'w-8 h-8')
        expect(result).to include('w-8 h-8')
        expect(result).not_to include('w-5 h-5')
      end
    end

    context 'with custom size w-4 h-4' do
      it 'uses the specified size' do
        result = helper.icon(:info, size: 'w-4 h-4')
        expect(result).to include('w-4 h-4')
      end
    end

    # CSS class parameter tests
    context 'with default css_class' do
      it 'renders without additional CSS classes' do
        result = helper.icon(:check)
        expect(result).to include('class="w-5 h-5"')
      end
    end

    context 'with custom css_class' do
      it 'includes custom CSS class' do
        result = helper.icon(:check, css_class: 'text-red-500')
        expect(result).to include('text-red-500')
        expect(result).to include('w-5 h-5')
      end
    end

    context 'with multiple custom css classes' do
      it 'includes all custom CSS classes' do
        result = helper.icon(:check, css_class: 'text-blue-600 hover:text-blue-800')
        expect(result).to include('text-blue-600 hover:text-blue-800')
      end
    end

    context 'with both custom size and css_class' do
      it 'includes both size and custom classes' do
        result = helper.icon(:check, size: 'w-6 h-6', css_class: 'text-green-500')
        expect(result).to include('w-6 h-6')
        expect(result).to include('text-green-500')
      end
    end

    # SVG attributes tests
    it 'includes correct SVG attributes' do
      result = helper.icon(:check)
      expect(result).to include('fill="none"')
      expect(result).to include('stroke="currentColor"')
      expect(result).to include('viewBox="0 0 24 24"')
      expect(result).to include('xmlns="http://www.w3.org/2000/svg"')
    end

    it 'includes path with correct stroke attributes' do
      result = helper.icon(:check)
      expect(result).to include('stroke-linecap="round"')
      expect(result).to include('stroke-linejoin="round"')
      expect(result).to include('stroke-width="2"')
    end

    # Multiple icons
    context 'when rendering multiple different icons' do
      it 'renders each icon with correct path data' do
        check_result = helper.icon(:check)
        edit_result = helper.icon(:edit)
        trash_result = helper.icon(:trash)

        expect(check_result).to include('M5 13l4 4L19 7')
        expect(edit_result).to include('M11 5H6a2 2 0 00-2 2v11')
        expect(trash_result).to include('M19 7l-.867 12.142')

        expect(check_result).not_to include(edit_result)
        expect(edit_result).not_to include(trash_result)
      end
    end
  end
end
