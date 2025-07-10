# mandm
🧩 Project Title: Location-Based Family Challenge Game App
📱 App Overview
An interactive location-based mobile app that allows families or users to participate in real-world challenges and quizzes at specific venues (e.g., clubs, resorts, schools). Each challenge is associated with a location, timer, media, and a set of quizzes. The app uses a progression system where each challenge or quiz unlocks the next upon completion.

🌍 Main Features
1. Challenge Management
Each Challenge includes:

id, name, lat, lng, radius

Media: image, charImage, guideImage, video

timer (duration in seconds), description, order

Progress Tracking:

isUnlocked, isCompleted, timeSpent, userPoints

Stored locally using sqflite in a table called challenges.

Progress saved when:

Challenge is started.

Timer runs.

User completes it (with points and duration).

Unlocked sequentially using local logic (order field).

2. Quiz Management
Each challenge has a list of Quiz questions:

id, question, answers (comma-separated), correctAnswer

points, challengeId

Progress Fields (local):

isCompleted, isUnlocked, userSelected

Quizzes are unlocked and answered sequentially (must answer one to unlock the next).

Data is pulled from an API like:

arduino
Copy
Edit
GET https://koshycoding.com/mandm/api/quizzes/{challengeId}
with Bearer token authorization.

Stored in local DB (quizzes table) with progress flags.

3. Timer Logic
Each challenge/quiz has a countdown (challengeTimer).

When time ends, the session ends (finishChallenge()).

Timer is paused on app background/exit (not fully implemented yet, but should be handled with WidgetsBindingObserver).

4. Local DB Schema (SQLite)
challenges
sql
Copy
Edit
CREATE TABLE challenges (
  id INTEGER PRIMARY KEY,
  name TEXT,
  lat REAL,
  lng REAL,
  radius REAL,
  image TEXT,
  char_image TEXT,
  guide_image TEXT,
  video TEXT,
  "order" INTEGER,
  timer INTEGER,
  activity_id INTEGER,
  type TEXT,
  status TEXT,
  description TEXT,
  created_at TEXT,
  updated_at TEXT,
  is_completed INTEGER DEFAULT 0,
  is_unlocked INTEGER DEFAULT 0,
  time_spent INTEGER DEFAULT 0,
  user_points INTEGER DEFAULT 0
)
quizzes
sql
Copy
Edit
CREATE TABLE quizzes (
  id INTEGER PRIMARY KEY,
  question TEXT,
  answers TEXT,
  correct_answer TEXT,
  points INTEGER,
  is_fake INTEGER,
  fake_text TEXT,
  fake_image TEXT,
  challenge_id INTEGER,
  created_at TEXT,
  updated_at TEXT,
  is_completed INTEGER DEFAULT 0,
  is_unlocked INTEGER DEFAULT 0,
  user_selected TEXT
)
✅ Flow Summary
User enters venue and starts an activity.

First challenge is unlocked.

Challenge opens with media + location check.

If within radius, challenge timer starts.

After challenge starts:

User sees related quizzes.

Quizzes are answered one-by-one.

Each correct answer unlocks the next.

After final quiz:

Challenge is marked completed.

Next challenge (by order) is unlocked.

🧱 Tools & Stack
Flutter frontend

Laravel backend API

Sqflite local database for offline support

Dio for network requests

CacheHelper for token/session storage

Google Maps for location tracking (planned or existing)

🔜 Remaining Suggestions
✅ Add WidgetsBindingObserver to save progress when app pauses/exits.

✅ Sync user progress to server if needed.

🟡 UI indicators (✔️ completed, 🔓 unlocked, 🔒 locked).

🟡 Handle deep links to resume from where user left.

🟢 Add analytics (time taken per quiz, skipped ones, total score).

🟢 Allow admin to define fake answers that trigger stories or side content.
