require 'rails_helper'

RSpec.describe ComponentHelper, type: :helper do
  describe '#card' do
    context 'with only content' do
      it 'renders a basic card with content' do
        result = helper.card { 'Card content' }
        expect(result).to include('bg-white rounded-lg border border-gray-200 shadow-sm p-6')
        expect(result).to include('Card content')
      end
    end

    context 'with title' do
      it 'renders card with title heading' do
        result = helper.card(title: 'My Title') { 'Content' }
        expect(result).to include('My Title')
        expect(result).to include('text-lg font-semibold text-gray-900 mb-4')
        expect(result).to include('Content')
      end
    end

    context 'with footer' do
      it 'renders card with footer section' do
        result = helper.card(footer: 'Footer text') { 'Content' }
        expect(result).to include('Footer text')
        expect(result).to include('mt-4 pt-4 border-t border-gray-200')
        expect(result).to include('Content')
      end
    end

    context 'with title and footer' do
      it 'renders card with both title and footer' do
        result = helper.card(title: 'Title', footer: 'Footer') { 'Content' }
        expect(result).to include('Title')
        expect(result).to include('Footer')
        expect(result).to include('Content')
      end
    end

    context 'with custom css_class' do
      it 'includes custom CSS classes' do
        result = helper.card(css_class: 'mb-4 custom-class') { 'Content' }
        expect(result).to include('mb-4 custom-class')
        expect(result).to include('bg-white rounded-lg')
      end
    end

    context 'with nil title' do
      it 'does not render title heading' do
        result = helper.card(title: nil) { 'Content' }
        expect(result).not_to include('<h3')
        expect(result).to include('Content')
      end
    end

    context 'with empty string title' do
      it 'renders title heading with empty string' do
        result = helper.card(title: '') { 'Content' }
        expect(result).to include('<h3')
      end
    end
  end

  describe '#simple_card' do
    context 'with basic content' do
      it 'renders a simple card without border or shadow' do
        result = helper.simple_card { 'Simple content' }
        expect(result).to include('bg-white rounded-lg p-4')
        expect(result).to include('Simple content')
        expect(result).not_to include('border')
        expect(result).not_to include('shadow')
      end
    end

    context 'with custom css_class' do
      it 'includes custom CSS classes' do
        result = helper.simple_card(css_class: 'mb-6 custom') { 'Content' }
        expect(result).to include('mb-6 custom')
        expect(result).to include('bg-white rounded-lg p-4')
      end
    end

    context 'with empty css_class' do
      it 'renders without extra classes' do
        result = helper.simple_card(css_class: '') { 'Content' }
        expect(result).to include('bg-white rounded-lg p-4')
        expect(result).to include('Content')
      end
    end

    context 'with HTML content' do
      it 'renders HTML content properly' do
        result = helper.simple_card { '<p>HTML content</p>'.html_safe }
        expect(result).to include('<p>HTML content</p>')
      end
    end
  end

  describe '#stat_card' do
    context 'with value and label only' do
      it 'renders basic stat card' do
        result = helper.stat_card(value: '150', label: 'Total Sessions')
        expect(result).to include('150')
        expect(result).to include('Total Sessions')
        expect(result).to include('bg-white rounded-lg border border-gray-200 shadow-sm p-6')
        expect(result).to include('text-3xl font-bold text-gray-900')
        expect(result).to include('text-sm text-gray-600 mt-1')
      end
    end

    context 'with icon' do
      it 'renders stat card with icon' do
        allow(helper).to receive(:icon).with(:check, size: 'w-8 h-8', css_class: 'text-cyan-600').and_return('<svg>icon</svg>'.html_safe)

        result = helper.stat_card(icon: :check, value: '100', label: 'Completed')
        expect(result).to include('100')
        expect(result).to include('Completed')
        expect(helper).to have_received(:icon)
      end
    end

    context 'with positive trend' do
      it 'renders trend in green' do
        result = helper.stat_card(value: '200', label: 'Users', trend: '+15%')
        expect(result).to include('+15%')
        expect(result).to include('text-green-600')
      end
    end

    context 'with negative trend' do
      it 'renders trend in red' do
        result = helper.stat_card(value: '50', label: 'Errors', trend: '-5%')
        expect(result).to include('-5%')
        expect(result).to include('text-red-600')
      end
    end

    context 'with custom css_class' do
      it 'includes custom CSS classes' do
        result = helper.stat_card(value: '75', label: 'Score', css_class: 'mb-8')
        expect(result).to include('mb-8')
      end
    end

    context 'without trend' do
      it 'does not render trend element' do
        result = helper.stat_card(value: '99', label: 'Items')
        expect(result).not_to include('text-green-600')
        expect(result).not_to include('text-red-600')
      end
    end
  end

  describe '#alert_card' do
    context 'with info type' do
      it 'renders info alert with blue styling' do
        allow(helper).to receive(:icon).with(:info, size: 'w-5 h-5').and_return('<svg>info</svg>'.html_safe)

        result = helper.alert_card(type: :info, message: 'Information message')
        expect(result).to include('bg-blue-50 border-blue-200 text-blue-800')
        expect(result).to include('Information message')
      end
    end

    context 'with success type' do
      it 'renders success alert with green styling' do
        allow(helper).to receive(:icon).with(:check, size: 'w-5 h-5').and_return('<svg>check</svg>'.html_safe)

        result = helper.alert_card(type: :success, message: 'Success message')
        expect(result).to include('bg-green-50 border-green-200 text-green-800')
        expect(result).to include('Success message')
      end
    end

    context 'with warning type' do
      it 'renders warning alert with yellow styling' do
        allow(helper).to receive(:icon).with(:warning, size: 'w-5 h-5').and_return('<svg>warning</svg>'.html_safe)

        result = helper.alert_card(type: :warning, message: 'Warning message')
        expect(result).to include('bg-yellow-50 border-yellow-200 text-yellow-800')
        expect(result).to include('Warning message')
      end
    end

    context 'with error type' do
      it 'renders error alert with red styling' do
        allow(helper).to receive(:icon).with(:x, size: 'w-5 h-5').and_return('<svg>x</svg>'.html_safe)

        result = helper.alert_card(type: :error, message: 'Error message')
        expect(result).to include('bg-red-50 border-red-200 text-red-800')
        expect(result).to include('Error message')
      end
    end

    context 'when dismissible is true' do
      it 'includes close button' do
        allow(helper).to receive(:icon).and_return('<svg>icon</svg>'.html_safe)

        result = helper.alert_card(type: :info, message: 'Dismissible', dismissible: true)
        expect(result).to include('×')
        expect(result).to include('this.parentElement.parentElement.remove()')
      end
    end

    context 'when dismissible is false' do
      it 'does not include close button' do
        allow(helper).to receive(:icon).and_return('<svg>icon</svg>'.html_safe)

        result = helper.alert_card(type: :info, message: 'Not dismissible', dismissible: false)
        expect(result).not_to include('×')
        expect(result).not_to include('remove()')
      end
    end

    context 'with custom css_class' do
      it 'includes custom CSS classes' do
        allow(helper).to receive(:icon).and_return('<svg>icon</svg>'.html_safe)

        result = helper.alert_card(type: :info, message: 'Message', css_class: 'mt-4')
        expect(result).to include('mt-4')
      end
    end

    it 'calls icon helper with correct parameters' do
      allow(helper).to receive(:icon).with(:info, size: 'w-5 h-5').and_return('<svg>info</svg>'.html_safe)

      helper.alert_card(type: :info, message: 'Test')
      expect(helper).to have_received(:icon).with(:info, size: 'w-5 h-5')
    end
  end

  describe '#section_header' do
    context 'with title only' do
      it 'renders section header with title' do
        result = helper.section_header('My Section')
        expect(result).to include('My Section')
        expect(result).to include('text-2xl font-bold text-gray-900')
        expect(result).to include('mb-6')
      end
    end

    context 'with title and subtitle' do
      it 'renders section header with both title and subtitle' do
        result = helper.section_header('My Section', subtitle: 'Section description')
        expect(result).to include('My Section')
        expect(result).to include('Section description')
        expect(result).to include('text-gray-600 mt-1')
      end
    end

    context 'with custom css_class' do
      it 'includes custom CSS classes' do
        result = helper.section_header('Title', css_class: 'custom-margin')
        expect(result).to include('custom-margin')
        expect(result).to include('mb-6')
      end
    end

    context 'without subtitle' do
      it 'does not render subtitle paragraph' do
        result = helper.section_header('Title Only')
        expect(result).to include('Title Only')
        expect(result).not_to include('<p')
      end
    end

    context 'with nil subtitle' do
      it 'does not render subtitle paragraph' do
        result = helper.section_header('Title', subtitle: nil)
        expect(result).to include('Title')
        expect(result).not_to include('<p')
      end
    end

    context 'with empty string subtitle' do
      it 'renders empty subtitle paragraph' do
        result = helper.section_header('Title', subtitle: '')
        expect(result).to include('Title')
        expect(result).to include('<p')
      end
    end
  end
end
