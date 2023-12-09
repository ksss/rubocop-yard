# Checks that there’s no N+1 query
#
# @note If `Database` isn't configured, auto-correct will not be available. (Only offense detection can be used)
#
# @note For the number of N+1 queries that can be detected by this cop, there are too few that can be corrected automatically
#
# @example
#   # bad
#   reservations = db.xquery('SELECT * FROM `reservations` WHERE `schedule_id` = ?', schedule_id).map do |reservation|
#     reservation[:user] = db.xquery('SELECT * FROM `users` WHERE `id` = ? LIMIT 1', id).first
#     reservation
#   end
#
#   # good
#   rows = db.xquery(<<~SQL, schedule_id)
#     SELECT
#       r.id AS reservation_id,
#       r.schedule_id AS reservation_schedule_id,
#       r.user_id AS reservation_user_id,
#       r.created_at AS reservation_created_at,
#       u.id AS user_id,
#       u.email AS user_email,
#       u.nickname AS user_nickname,
#       u.staff AS user_staff,
#       u.created_at AS user_created_at
#     FROM `reservations` AS r
#     INNER JOIN users u ON u.id = r.user_id
#     WHERE r.schedule_id = ?
#   SQL
#
#   # bad
#   courses.map do |course|
#     teacher = db.xquery('SELECT * FROM `users` WHERE `id` = ?', course[:teacher_id]).first
#   end
#
#   # good
#   # This is similar to ActiveRecord's preload
#   # c.f. https://guides.rubyonrails.org/active_record_querying.html#preload
#   courses.map do |course|
#     @users_by_id ||= db.xquery('SELECT * FROM `users` WHERE `id` IN (?)', courses.map { |course| course[:teacher_id] }).each_with_object({}) { |v, hash| hash[v[:id]] = v }
#     teacher = @users_by_id[course[:teacher_id]]
#   end
class NPlusOneQuery < Base
end
