require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#flash_class' do
    context 'when type is notice' do
      it 'returns cyan color classes' do
        expect(helper.flash_class(:notice)).to eq('bg-cyan-50 border-cyan-200 text-cyan-800')
      end
    end

    context 'when type is alert' do
      it 'returns red color classes' do
        expect(helper.flash_class(:alert)).to eq('bg-red-50 border-red-200 text-red-800')
      end
    end

    context 'when type is error' do
      it 'returns red color classes' do
        expect(helper.flash_class(:error)).to eq('bg-red-50 border-red-200 text-red-800')
      end
    end

    context 'when type is success' do
      it 'returns green color classes' do
        expect(helper.flash_class(:success)).to eq('bg-green-50 border-green-200 text-green-800')
      end
    end

    context 'when type is warning' do
      it 'returns yellow color classes' do
        expect(helper.flash_class(:warning)).to eq('bg-yellow-50 border-yellow-200 text-yellow-800')
      end
    end

    context 'when type is unknown' do
      it 'returns gray color classes' do
        expect(helper.flash_class(:unknown_type)).to eq('bg-gray-50 border-gray-200 text-gray-800')
      end
    end

    context 'when type is string' do
      it 'converts to symbol and returns correct classes' do
        expect(helper.flash_class('notice')).to eq('bg-cyan-50 border-cyan-200 text-cyan-800')
      end
    end
  end

  describe '#status_badge' do
    context 'when status is active' do
      it 'returns a badge with green colors' do
        result = helper.status_badge('active')
        expect(result).to include('bg-green-100 text-green-800')
        expect(result).to include('Active')
      end
    end

    context 'when status is inactive' do
      it 'returns a badge with gray colors' do
        result = helper.status_badge('inactive')
        expect(result).to include('bg-gray-100 text-gray-800')
        expect(result).to include('Inactive')
      end
    end

    context 'when status is pending' do
      it 'returns a badge with yellow colors' do
        result = helper.status_badge('pending')
        expect(result).to include('bg-yellow-100 text-yellow-800')
        expect(result).to include('Pending')
      end
    end

    context 'when status is cancelled' do
      it 'returns a badge with red colors' do
        result = helper.status_badge('cancelled')
        expect(result).to include('bg-red-100 text-red-800')
        expect(result).to include('Cancelled')
      end
    end

    context 'when status is nil' do
      it 'returns a badge with default gray colors and Unknown text' do
        result = helper.status_badge(nil)
        expect(result).to include('bg-gray-100 text-gray-800')
        expect(result).to include('Unknown')
      end
    end

    context 'when status is unknown' do
      it 'returns a badge with default gray colors' do
        result = helper.status_badge('custom_status')
        expect(result).to include('bg-gray-100 text-gray-800')
        expect(result).to include('Custom Status')
      end
    end

    context 'when status is a symbol' do
      it 'raises an error because symbols do not have titleize method' do
        expect { helper.status_badge(:active) }.to raise_error(NoMethodError)
      end
    end

    it 'includes proper span attributes' do
      result = helper.status_badge('active')
      expect(result).to include('px-2 py-1 rounded-full text-xs font-medium')
    end
  end

  describe '#icon_svg' do
    context 'when type is check' do
      it 'returns check icon SVG' do
        result = helper.icon_svg(:check)
        expect(result).to include('<svg')
        expect(result).to include('w-5 h-5')
        expect(result).to include('M5 13l4 4L19 7')
      end
    end

    context 'when type is x' do
      it 'returns x icon SVG' do
        result = helper.icon_svg(:x)
        expect(result).to include('<svg')
        expect(result).to include('M6 18L18 6M6 6l12 12')
      end
    end

    context 'when type is info' do
      it 'returns info icon SVG' do
        result = helper.icon_svg(:info)
        expect(result).to include('<svg')
        expect(result).to include('M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z')
      end
    end

    context 'when type is warning' do
      it 'returns warning icon SVG' do
        result = helper.icon_svg(:warning)
        expect(result).to include('<svg')
        expect(result).to include('M12 9v2m0 4h.01m-6.938 4h13.856')
      end
    end

    context 'when type is unknown' do
      it 'returns default info icon SVG' do
        result = helper.icon_svg(:unknown_icon)
        expect(result).to include('<svg')
        expect(result).to include('M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z')
      end
    end

    context 'with custom css_class' do
      it 'includes the custom CSS class' do
        result = helper.icon_svg(:check, css_class: 'text-red-500')
        expect(result).to include('text-red-500')
      end
    end

    context 'with custom size' do
      it 'uses the custom size instead of default' do
        result = helper.icon_svg(:check, css_class: 'w-8 h-8')
        expect(result).to include('w-8 h-8')
        expect(result).not_to include('w-5 h-5')
      end
    end

    it 'includes proper SVG attributes' do
      result = helper.icon_svg(:check)
      expect(result).to include('fill="none"')
      expect(result).to include('stroke="currentColor"')
      expect(result).to include('viewBox="0 0 24 24"')
    end
  end

  describe '#smart_truncate' do
    context 'when text is shorter than length' do
      it 'returns the full text' do
        text = 'Short text'
        expect(helper.smart_truncate(text)).to eq('Short text')
      end
    end

    context 'when text is exactly at length' do
      it 'returns the full text without ellipsis' do
        text = 'a' * 100
        expect(helper.smart_truncate(text, length: 100)).to eq(text)
      end
    end

    context 'when text is longer than length' do
      it 'truncates and adds ellipsis' do
        text = 'a' * 150
        result = helper.smart_truncate(text, length: 100)
        expect(result).to eq("#{'a' * 100}...")
        expect(result.length).to eq(103)
      end
    end

    context 'when text is nil' do
      it 'returns empty string' do
        expect(helper.smart_truncate(nil)).to eq('')
      end
    end

    context 'when text is empty string' do
      it 'returns empty string' do
        expect(helper.smart_truncate('')).to eq('')
      end
    end

    context 'with custom length parameter' do
      it 'truncates to custom length' do
        text = 'This is a long text that should be truncated'
        result = helper.smart_truncate(text, length: 10)
        expect(result).to eq('This is a ...')
      end
    end

    context 'with default length parameter' do
      it 'uses default length of 100' do
        text = 'a' * 101
        result = helper.smart_truncate(text)
        expect(result).to eq("#{'a' * 100}...")
      end
    end
  end
end
