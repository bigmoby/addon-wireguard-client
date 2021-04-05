## What’s changed

## 💣 Breaking changes

- Add the PostUp and PostDown custom parameters
- 💣 Breaking changes: add these lines to your current configuration:

 `post_up: iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE`

 `post_down: iptables -t nat -D POSTROUTING -o wg0 -j MASQUERADE`

## 🧰 Maintenance

- Update add-on configuration for Supervisor 2021.2

## ⬆️ Dependency updates

- Upgrade add-on base image to 9.1.2