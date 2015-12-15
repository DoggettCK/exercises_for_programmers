# FirstPass

As of now, this only runs in iex, until I finish the UI.

  1. `iex -S mix`
  2. Call GeneratePassword.generate_password with the minimum length, number of special chars, and number of digits. 
  ```
  iex(1)> GeneratePassword.generate_password(16, 2, 3)
  "VLxJ^@26iFFAqzX2"
  
  iex(2)> 1..10 |> Enum.map fn(x) -> GeneratePassword.generate_password(16, 2, 3) end
  ["rR#8ddQZ8^D9bcGn", "yWG&#HnWowcT621Y", "wg9FIGS*9LsE&bc2", "P?7@mO8ErBVTi1rp",
   "zkue8EexD*49d@dK", "Nnfs8r6OREt#g9F*", "Xs23jLBm`8OVx&YS", "*hTT!DC7Xlh3zy2E",
    "G8I`#nNRXgOc6VU4", "j8$myXhPSXr3v`f8"]
  ```

## Starting Phoenix app:

  1. Install dependencies with `mix deps.get`
  2. Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  3. Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: http://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
