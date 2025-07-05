require 'rails_helper'

RSpec.describe Advertisement, type: :model do
  describe 'バリデーション' do
    subject { build(:advertisement) }

    it { is_expected.to be_valid }

    describe 'title' do
      it { is_expected.to validate_presence_of(:title) }
      it { is_expected.to validate_length_of(:title).is_at_most(255) }

      context 'タイトルが空の場合' do
        subject { build(:advertisement, title: nil) }
        it { is_expected.not_to be_valid }
      end

      context 'タイトルが256文字の場合' do
        subject { build(:advertisement, title: 'a' * 256) }
        it { is_expected.not_to be_valid }
      end
    end

    describe 'link_url' do
      it { is_expected.to validate_presence_of(:link_url) }

      context '有効なURLの場合' do
        valid_urls = [
          'https://example.com',
          'http://example.com',
          'https://example.com/path',
          'https://example.com/path?param=value',
          'http://example.com:8080',
          'https://example.com:443/path'
        ]

        valid_urls.each do |url|
          it "#{url}は有効" do
            advertisement = build(:advertisement, link_url: url)
            expect(advertisement).to be_valid
          end
        end
      end

      context '無効なURLの場合' do
        invalid_urls = [
          'not-a-url',
          'ftp://example.com',
          'example.com',
          'https://',
          'http://',
          'mailto:test@example.com'
        ]

        invalid_urls.each do |url|
          it "#{url}は無効" do
            advertisement = build(:advertisement, link_url: url)
            expect(advertisement).not_to be_valid
            expect(advertisement.errors[:link_url]).to include('は有効なURL形式である必要があります')
          end
        end
      end
    end

    describe 'image_url' do
      context '有効なURLの場合' do
        it '有効' do
          advertisement = build(:advertisement, image_url: 'https://example.com/image.jpg')
          expect(advertisement).to be_valid
        end
      end

      context '無効なURLの場合' do
        it '無効' do
          advertisement = build(:advertisement, image_url: 'not-a-url')
          expect(advertisement).not_to be_valid
          expect(advertisement.errors[:image_url]).to include('は有効なURL形式である必要があります')
        end
      end

      context '空の場合' do
        it '有効' do
          advertisement = build(:advertisement, image_url: nil)
          expect(advertisement).to be_valid
        end
      end
    end

    describe 'ad_type' do
      it { is_expected.to validate_presence_of(:ad_type) }

      context '有効な値の場合' do
        it 'imageは有効' do
          advertisement = build(:advertisement, ad_type: 'image')
          expect(advertisement).to be_valid
        end

        it 'videoは有効' do
          advertisement = build(:advertisement, ad_type: 'video')
          expect(advertisement).to be_valid
        end
      end

      context 'nil値の場合' do
        it 'nil値は拒否される' do
          advertisement = build(:advertisement)
          advertisement.ad_type = nil
          expect(advertisement).not_to be_valid
          expect(advertisement.errors[:ad_type]).to include('を入力してください')
        end
      end
    end

    describe 'ad_size' do
      it { is_expected.to validate_presence_of(:ad_size) }

      context '有効な値の場合' do
        it 'verticalは有効' do
          advertisement = build(:advertisement, ad_size: 'vertical')
          expect(advertisement).to be_valid
        end

        it 'horizontalは有効' do
          advertisement = build(:advertisement, ad_size: 'horizontal')
          expect(advertisement).to be_valid
        end

        it 'squareは有効' do
          advertisement = build(:advertisement, ad_size: 'square')
          expect(advertisement).to be_valid
        end
      end

      context 'nil値の場合' do
        it 'nil値は拒否される' do
          advertisement = build(:advertisement)
          advertisement.ad_size = nil
          expect(advertisement).not_to be_valid
          expect(advertisement.errors[:ad_size]).to include('を入力してください')
        end
      end
    end

  end

  describe 'enum' do
    describe 'ad_type' do
      it '正しい値が定義されている' do
        expect(Advertisement.ad_types).to eq({
          'image' => 'image',
          'video' => 'video'
        })
      end

      it '有効な値のみが許可される' do
        expect { Advertisement.new(ad_type: 'image') }.not_to raise_error
        expect { Advertisement.new(ad_type: 'video') }.not_to raise_error
        expect { Advertisement.new(ad_type: 'invalid') }.to raise_error(ArgumentError)
      end

      it 'プレフィックス付きメソッドが利用可能' do
        advertisement = create(:advertisement, ad_type: 'image')
        expect(advertisement.ad_type_image?).to be true
        expect(advertisement.ad_type_video?).to be false
      end
    end

    describe 'ad_size' do
      it '正しい値が定義されている' do
        expect(Advertisement.ad_sizes).to eq({
          'vertical' => 'vertical',
          'horizontal' => 'horizontal',
          'square' => 'square'
        })
      end

      it '有効な値のみが許可される' do
        expect { Advertisement.new(ad_size: 'vertical') }.not_to raise_error
        expect { Advertisement.new(ad_size: 'horizontal') }.not_to raise_error
        expect { Advertisement.new(ad_size: 'square') }.not_to raise_error
        expect { Advertisement.new(ad_size: 'invalid') }.to raise_error(ArgumentError)
      end

      it 'プレフィックス付きメソッドが利用可能' do
        advertisement = create(:advertisement, ad_size: 'square')
        expect(advertisement.ad_size_square?).to be true
        expect(advertisement.ad_size_vertical?).to be false
      end
    end
  end

  describe 'スコープ' do
    let!(:active_ad) { create(:advertisement, :active) }
    let!(:inactive_ad) { create(:advertisement, active: false) }
    let!(:image_ad) { create(:advertisement, ad_type: 'image') }
    let!(:video_ad) { create(:advertisement, :video) }
    let!(:square_ad) { create(:advertisement, ad_size: 'square') }
    let!(:vertical_ad) { create(:advertisement, :vertical) }

    describe '.active' do
      it 'アクティブな広告のみを返す' do
        expect(Advertisement.active).to include(active_ad)
        expect(Advertisement.active).not_to include(inactive_ad)
      end
    end

    describe '.by_type' do
      it '指定した種別の広告のみを返す' do
        expect(Advertisement.by_type('image')).to include(image_ad)
        expect(Advertisement.by_type('image')).not_to include(video_ad)
        expect(Advertisement.by_type('video')).to include(video_ad)
        expect(Advertisement.by_type('video')).not_to include(image_ad)
      end
    end

    describe '.by_size' do
      it '指定したサイズの広告のみを返す' do
        expect(Advertisement.by_size('square')).to include(square_ad)
        expect(Advertisement.by_size('square')).not_to include(vertical_ad)
        expect(Advertisement.by_size('vertical')).to include(vertical_ad)
        expect(Advertisement.by_size('vertical')).not_to include(square_ad)
      end
    end

    describe 'スコープの組み合わせ' do
      let!(:active_square_image) { create(:advertisement, :active, ad_type: 'image', ad_size: 'square') }

      it '複数のスコープを組み合わせて使用できる' do
        result = Advertisement.active.by_type('image').by_size('square')
        expect(result).to include(active_square_image)
        expect(result).not_to include(inactive_ad)
        expect(result).not_to include(video_ad)
        expect(result).not_to include(vertical_ad)
      end
    end
  end

  describe 'インスタンスメソッド' do
    let(:advertisement) { create(:advertisement, tags: ['タグ1', 'タグ2', 'タグ3']) }

    describe '#tag_list' do
      it 'タグをカンマ区切り文字列で返す' do
        expect(advertisement.tag_list).to eq('タグ1, タグ2, タグ3')
      end

      context 'タグが空の場合' do
        let(:advertisement) { create(:advertisement, tags: []) }
        it '空文字列を返す' do
          expect(advertisement.tag_list).to eq('')
        end
      end
    end

    describe '#tag_list=' do
      it 'カンマ区切り文字列からタグ配列を設定する' do
        advertisement.tag_list = '新しいタグ1, 新しいタグ2'
        expect(advertisement.tags).to eq(['新しいタグ1', '新しいタグ2'])
      end

      it '空白を除去する' do
        advertisement.tag_list = ' タグ1 , タグ2 '
        expect(advertisement.tags).to eq(['タグ1', 'タグ2'])
      end

      it '空のタグを除去する' do
        advertisement.tag_list = 'タグ1, , タグ2'
        expect(advertisement.tags).to eq(['タグ1', 'タグ2'])
      end
    end

    describe '#display_name' do
      it '表示用の名前を返す' do
        advertisement = create(:advertisement, title: 'テスト広告', ad_type: 'image', ad_size: 'square')
        expect(advertisement.display_name).to eq('テスト広告 (Image - Square)')
      end
    end

    describe '種別判定メソッド' do
      context '画像広告の場合' do
        let(:advertisement) { create(:advertisement, ad_type: 'image') }

        it '#image?がtrueを返す' do
          expect(advertisement.image?).to be true
        end

        it '#video?がfalseを返す' do
          expect(advertisement.video?).to be false
        end
      end

      context '動画広告の場合' do
        let(:advertisement) { create(:advertisement, :video) }

        it '#image?がfalseを返す' do
          expect(advertisement.image?).to be false
        end

        it '#video?がtrueを返す' do
          expect(advertisement.video?).to be true
        end
      end
    end

    describe 'サイズ判定メソッド' do
      context '正方形の場合' do
        let(:advertisement) { create(:advertisement, ad_size: 'square') }

        it '#square?がtrueを返す' do
          expect(advertisement.square?).to be true
        end

        it '#vertical?がfalseを返す' do
          expect(advertisement.vertical?).to be false
        end

        it '#horizontal?がfalseを返す' do
          expect(advertisement.horizontal?).to be false
        end
      end

      context '縦長の場合' do
        let(:advertisement) { create(:advertisement, :vertical) }

        it '#vertical?がtrueを返す' do
          expect(advertisement.vertical?).to be true
        end

        it '#square?がfalseを返す' do
          expect(advertisement.square?).to be false
        end

        it '#horizontal?がfalseを返す' do
          expect(advertisement.horizontal?).to be false
        end
      end

      context '横長の場合' do
        let(:advertisement) { create(:advertisement, :horizontal) }

        it '#horizontal?がtrueを返す' do
          expect(advertisement.horizontal?).to be true
        end

        it '#square?がfalseを返す' do
          expect(advertisement.square?).to be false
        end

        it '#vertical?がfalseを返す' do
          expect(advertisement.vertical?).to be false
        end
      end
    end
  end

  describe 'コールバック' do
    describe 'before_validation :normalize_tags' do
      context 'タグが文字列の場合' do
        it '配列に変換する' do
          advertisement = build(:advertisement, tags: "タグ1, タグ2, タグ3")
          expect(advertisement.tags).to eq(['タグ1', 'タグ2', 'タグ3'])
        end
      end

      context 'タグが配列で空文字列が含まれる場合' do
        it '空文字列を除去する' do
          advertisement = build(:advertisement, tags: ['タグ1', '', 'タグ2', '  ', 'タグ3'])
          advertisement.valid?
          expect(advertisement.tags).to eq(['タグ1', 'タグ2', 'タグ3'])
        end
      end

      context 'タグが既に正しい配列の場合' do
        it '変更しない' do
          original_tags = ['タグ1', 'タグ2']
          advertisement = build(:advertisement, tags: original_tags)
          advertisement.valid?
          expect(advertisement.tags).to eq(original_tags)
        end
      end
    end
  end

  describe 'ファクトリー' do
    describe '基本ファクトリー' do
      it '有効な広告を作成する' do
        advertisement = build(:advertisement)
        expect(advertisement).to be_valid
      end
    end

    describe 'trait :active' do
      it 'アクティブな広告を作成する' do
        advertisement = create(:advertisement, :active)
        expect(advertisement.active).to be true
      end
    end

    describe 'trait :video' do
      it '動画広告を作成する' do
        advertisement = create(:advertisement, :video)
        expect(advertisement.ad_type).to eq('video')
        expect(advertisement.image_url).to eq('https://example.com/video-thumb.jpg')
      end
    end

    describe 'trait :vertical' do
      it '縦長の広告を作成する' do
        advertisement = create(:advertisement, :vertical)
        expect(advertisement.ad_size).to eq('vertical')
      end
    end

    describe 'trait :horizontal' do
      it '横長の広告を作成する' do
        advertisement = create(:advertisement, :horizontal)
        expect(advertisement.ad_size).to eq('horizontal')
      end
    end

    describe 'trait :without_image' do
      it '画像URLなしの広告を作成する' do
        advertisement = create(:advertisement, :without_image)
        expect(advertisement.image_url).to be_nil
      end
    end

    describe 'trait :without_alt_text' do
      it '代替テキストなしの広告を作成する' do
        advertisement = create(:advertisement, :without_alt_text)
        expect(advertisement.alt_text).to be_nil
      end
    end

    describe 'trait :with_many_tags' do
      it '多くのタグを持つ広告を作成する' do
        advertisement = create(:advertisement, :with_many_tags)
        expect(advertisement.tags).to eq(['タグ1', 'タグ2', 'タグ3', 'タグ4', 'タグ5'])
      end
    end
  end
end
