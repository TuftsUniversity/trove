require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe "#limit_text_length" do
    let(:text) do
      { value: ["One morning, when Gregor Samsa woke from troubled dreams, he found himself transformed in his bed end
into a horrible vermin. He lay on his armour-like back, and if he li"] }
    end

    let(:long_text) do
      { value: ["It was at this juncture that Mr. Monck Mason (whose voyage from Dover to Weilburg in the balloon,
Nassau, occasioned so much excitement in 1837,) conceived the idea of employing the principle of the Archimedean screw
for the purpose of propulsion through the air—rightly attributing the failure of Mr. Henson’s scheme, and of Sir George
Cayley’s, to the interruption of surface in the independent vanes. He made the first public experiment at Willis’s
Rooms, but afterward removed his model to the Adelaide Gallery."] }
    end

    it 'returns the string if text is 170 characters or less' do
      expect(helper.limit_text_length(text)).to eq(text[:value].first)
    end

    it 'returns a truncated string if text is more than 170 characters' do
      truncated_text = helper.limit_text_length(long_text)

      expect(truncated_text.length).to be < 170
      expect(truncated_text).to eq("It was at this juncture that Mr. Monck Mason (whose voyage from Dover to Weilburg in the balloon,
Nassau, occasioned so much excitement in 1837,)...")
    end
  end
end