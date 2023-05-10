INSERT INTO public.users (display_name, handle, email, cognito_user_id)
VALUES
  ('Daniel Amadi', 'danielamadi' ,'danielamadi000@gmail.com' , 'MOCK'),
  ('Kachi Amadi', 'kachiamadi' ,'princedanny922@gmail.com' , 'MOCK');
   ('James Amadi', 'jamesamadi' ,'james@gmail.com' , 'MOCK');

INSERT INTO public.activities (user_uuid, message, expires_at)
VALUES
  (
    (SELECT uuid from public.users WHERE users.handle = 'danielamadi' LIMIT 1),
    'This was imported as seed data!',
    current_timestamp + interval '10 day'
  )