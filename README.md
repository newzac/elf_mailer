Elf Mailer
------------

This is a couples focused secret santa app that works with mailgun or other api based mailer. It does logging with blind mailing of matches.
Usage:
```bash
./run.rb <participants.yml>
```

The participants YAML file should look like this
```yaml
Joe:
  first_name: Joe
  last_name: Smith
  email: joe@example.com
  partner: Jane
Jane:
  first_name: Jane
  last_name: Johnson
  email: jane@example.com
  partner: Joe
```

Currently it's very basic, but works well.
