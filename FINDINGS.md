# Exam module findings

Review of the School ERP exam app across the initial import (`8438652`), the validator pass (`2132387`), and the fix on `main` (`494a539`). Fifteen tests in `school_erp/exams/tests.py` cover the fixed behavior.

## Fixed

These defects stopped scheduling or grading from running, or they produced the wrong timetable or score.

| Area | What was wrong | What it does now |
| --- | --- | --- |
| `ExamMode` | Declared as an empty `Model`. `ExamSchedule.mode` read `ExamMode.choices`, which does not exist, and the default was the tuple `('Offline', 'Offline')`. Importing the models crashed. | `ExamMode` is a `TextChoices` value. The stored default is `'Offline'`. |
| Schema | `Student`, `GradeScale`, `ExamResult`, `Question`, `StudentAnswer`, and `AssessmentParameter` had no migrations. `ExamSchedule` had gained `mode`, `total_marks`, `passing_marks`, and `is_result_published` in code only. | Migration `0004_exam_marks_results_and_questions` creates those tables and columns. Existing schedules get `total_marks=100`, `passing_marks=35`, `mode=Offline`. |
| Class clash | Overlap used `start <= existing_end` and `end <= existing_end`, so an exam that fully contained another was allowed. Back-to-back exams were treated as clashes. Only the same calendar date was checked, and an update clashed with itself. | Overlap is half-open: `[start, end)`. The day before and the day after are included. The row being saved is excluded. |
| Teacher | Availability was a same-day slot check only. A teacher could be given two exams at once. A missing slot and a slot that did not cover the exam were the same failure. | The slot must cover the exam. A second overlapping duty is a clash. An exam that crosses midnight is rejected. |
| Schedule payload | `smart_schedule_view` read `request.body` and created an `ExamSchedule` without `total_marks`, `passing_marks`, or `mode`, so `save()` failed validation. The first version also set `schedule = False` and then looped on `scheduled`. | The view reads `request.data`, fills marks and mode, and stops if a slot cannot be found within 14 days. |
| Student clash in the planner | Clash was `abs(new_start - old_start) < this_duration`. A long earlier exam and a short later one could overlap without being detected. | Both intervals are compared. |
| Hall capacity | Usage was a running total for the whole date, so a full morning exam blocked the same hall in the afternoon. | Capacity counts only exams that overlap that slot. The hall can be used again after the exam ends. |
| Grading endpoint | `evaluate_exam` was not routed. The first version filtered `sudent_id` and `exam_student_id`. The second treated JSON answers as model instances (`answer.selected_option`, `answer.question.correct_option`) and wrote `grade_scale`, while the field is `graded_scale`. `grace_marks` did not exist. `graded_scale` was required, so an unmatched score could not be saved. | `POST /api/evaluate/` stores answers, scores the question key, and writes `graded_scale` (nullable) plus `grace_marks`. |
| Grace check | Grace was added first, then checked by calling the grace rule on the already-adjusted score. A legal grace award failed with "Invalid grace marks applied". `Decimal` passing marks minus a `float` score raised `TypeError`. | The check uses the raw score. Passing and total marks are converted with `float`. At most 5 marks are awarded, and only the exact amount needed to pass. |
| Answer checks | Any student id that existed was accepted. Options were not checked against the exam subject. Duplicate questions in one payload were stored twice. The open-window check compared `datetime.now().time()` with the start time and ignored the date, so grading after the exam was refused and a future exam on today's clock could pass. | The student must be in the exam's class. The question must belong to the exam subject and the option must exist. Duplicates are rejected. The window helper uses the full start and end datetime. Grading itself does not require the window to be open, because marking happens after the exam. |
| Permissions setting | `DEFAULT_PERMISSION_CALSSES` was misspelled, so the intended default of `IsAuthenticated` was never applied. | The key is `DEFAULT_PERMISSION_CLASSES`. |
| Serializer name | The schedule serializer was `ExamScheduleSerialzer`. | The class is `ExamScheduleSerializer`. The old name remains as an alias. |
| Marks rules | `passing_marks` could be larger than `total_marks`. Duration `0` was allowed. A grade band could have `min_score` above `max_score`. An availability slot could end before it started. | Those four cases raise `ValidationError` on save. |

Grace rule, as implemented: if `passing_marks - raw_score` is greater than 0 and at most 5, that difference is the grace. Otherwise grace is 0. `marks_obtained` on `ExamResult` is the score after grace.

## Still open

These were not changed in `494a539`.

### Scheduling

- The planner keeps one clock for the whole batch. A clash moves that clock forward, so a later exam cannot take a gap earlier in the day.
- It does not try another hall. `venue_id` is taken from the request.
- Capacity is the number in the request's `venues` map, not `Venue.capacity`.
- Student ids in the planner payload are not loaded from `Student` and are not checked against the class roll. They only prevent two requested exams from sharing a person at the same time.
- Manual `ExamSchedule` create does not look at hall capacity or at exams already booked in that hall. Overlap protection there is class and teacher only.
- Exams already in the database are invisible to the in-memory hall and student checks. They are visible only when `ExamSchedule.save()` runs the class and teacher validators.
- "This is a clash, try the next slot" is decided by searching the error text for `clash`, `not available`, or `no availability`.
- The failure text always says "within 14 days", even if `PLANNING_WINDOW` is changed.
- `mode` is stored and not used. Online and offline exams follow the same rules.

### Grading

- `POST /api/evaluate/` does not pass `require_open_window=True`, so a script can grade before the exam starts. The window check exists and is tested on its own.
- A second call updates answers it sends and leaves any previously stored answers it does not mention. The score includes those leftover rows.
- Unanswered questions add nothing. There is no check that the question-paper total matches `ExamSchedule.total_marks`. `validate_question_paper` is not called by a view.
- `calculate_grace_marks` accepts `student_id` and does not use it. The 5-mark cap is a constant.
- `marks_obtained` is the final score, and `grace_marks` is stored separately. A reader who treats `marks_obtained` as the raw paper score will double-count grace.
- `is_result_published` is never set by evaluation.
- Grade bands are global. Overlapping bands resolve to the one with the higher `min_score`. A score that falls in a gap is `"Ungraded"`.
- Marks mix `Decimal` totals with `FloatField` scores.

### API and project setup

- Any authenticated user can create exams and write results. There is no teacher, student, or admin role on these endpoints.
- Serializers exist for `Question`, `StudentAnswer`, and `ExamResult`, but there are no viewsets for them. `AssessmentParameter` is unused.
- `Class.name` and `Subject.name` are not unique per board.
- `SECRET_KEY` is committed, `DEBUG` is `True`, and `ALLOWED_HOSTS` is empty. That is the generated development settings file, not a production configuration.
- `db.sqlite3` and compiled `__pycache__` files are in git.
- Migration `0003` added `ExamSchedule.teacher` with a temporary default of teacher id `650` before dropping the default. Fresh installs do not depend on that id; existing databases that applied `0003` already have the column.
- Branch `cursor/fix-tag-sequence-number-185b` (draft PR about cigarette-tag sequence numbers) is history on this repository and is not part of the exam app.

## Verification

From `school_erp/`:

```bash
python manage.py test exams
```

The suite checks contained-interval clashes, back-to-back exams, self-update, teacher double booking, passing marks above the total, parallel and sequential planning, an unschedulable request, authentication, grace within and beyond 5 marks, invalid options, wrong subject, duplicate answers, a student from another class, the exam window, and an empty question paper.
