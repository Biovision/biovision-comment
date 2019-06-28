# Biovision::Comment

Компонент с комментариями для проектов на базе `Biovision`.

Находится в стадии разработки. Используйте на свой страх и риск.

## Использование

### Подготовка моделей

Для моделей, которым нужны комментарии, следует в классе добавить это:

```ruby
has_many :comments, as: :commentable
```

Тамже всем моделям с комментариями нужно поле `comments_count` для счётчика
комментарием:

```bash
rails g migration add_comments_count_to_sample comments_count:integer
```

```ruby
# frozen_string_literal: true

# Add counter for comments to Sample model
class AddCommentsCountToSample < ActiveRecord::Migration[5.2]
  def change
    add_column :samples, :comments_count, :integer, default: 0, null: false
  end
end
```

### В представлениях

Для вывода комментариев используется код такого вида:

```erb
<%= render(partial: 'comments/section', locals: { entity: entity }) %>
```

Здесь `entity` — это объект модели с комментариями.

### Стили и сценарии

Для работы переноса формы ответа нужно включить в сценарии JS код компонента
в `application.js` после добавления `biovision/base/biovision`:

```
//= require biovision/comment/biovision-comments
```

Стили по умолчанию описаны в `biovision/comment/comments.scss`.

## Установка

Нужно добавить компонент в `Gemfile`:

```ruby
gem 'biovision-comment', git: 'https://github.com/Biovision/biovision-comment'
# gem 'biovision-comment', path: '/Users/maxim/Projects/Biovision/gems/biovision-comment'
```

После этого:

```bash
$ bundle
$ rails railties:install:migrations
$ rails db:migrate
```

## Вклад в разработку

Особых инструкций нет. Fork/update/PR, как обычно. Или просто опишите свои идеи
в разделе `issues`.

## Лицензия

[MIT License](http://opensource.org/licenses/MIT).

Продукт предоставляется «как есть». Используйте на свой страх и риск.
