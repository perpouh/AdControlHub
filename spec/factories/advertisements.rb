FactoryBot.define do
  factory :advertisement do
    title { "テスト広告" }
    link_url { "https://example.com" }
    image_url { "https://example.com/image.jpg" }
    ad_type { "image" }
    ad_size { "square" }
    alt_text { "テスト広告の代替テキスト" }
    tags { ["テスト", "広告", "サンプル"] }
    active { false }

    trait :active do
      active { true }
    end

    trait :video do
      ad_type { "video" }
      image_url { "https://example.com/video-thumb.jpg" }
    end

    trait :vertical do
      ad_size { "vertical" }
    end

    trait :horizontal do
      ad_size { "horizontal" }
    end

    trait :without_image do
      image_url { nil }
    end

    trait :without_alt_text do
      alt_text { nil }
    end

    trait :with_many_tags do
      tags { ["タグ1", "タグ2", "タグ3", "タグ4", "タグ5"] }
    end
  end
end
