# Anagrams

![Anagrams](/anagrams.png)

To start your Phoenix server:

  * Install prerequisites with `brew bundle`
  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Interesting bits

  * Client-side [logic](https://github.com/joshuafleck/anagrams/blob/master/lib/anagrams_web/elm/Main.elm) for the anagram searching, written in [Elm](http://elm-lang.org/).
  * Client-side [logic](https://github.com/joshuafleck/anagrams/blob/master/lib/anagrams_web/templates/page/index.html.eex) for the dictionary upload.
  * Server-side [logic](https://github.com/joshuafleck/anagrams/blob/master/lib/anagrams_web/channels/room_channel.ex) for anagram searching. Communication with the client-side is accomplished using Phoenix [Channels](https://hexdocs.pm/phoenix/channels.html).
  * Server-side [logic](https://github.com/joshuafleck/anagrams/blob/master/lib/anagrams_web/controllers/page_controller.ex) for the dictionary upload. The dictionary state is maintained using an [Agent](https://hexdocs.pm/elixir/Agent.html).

## Todo list

- [ ] Add automated testing
- [ ] Allow for multiple users
- [ ] Purge dictionaries after a timeout period

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
