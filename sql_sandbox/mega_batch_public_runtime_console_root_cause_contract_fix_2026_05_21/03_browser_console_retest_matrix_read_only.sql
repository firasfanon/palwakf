-- Browser/Console Retest Matrix — READ ONLY TEMPLATE
select * from (values
('/home','page renders + console clean'),
('/home/news','page renders + console clean'),
('/home/news/1963512572','detail renders + console clean'),
('/home/announcements','page renders + console clean'),
('/home/announcements/1295789704','detail renders + console clean'),
('/home/services','page renders + console clean'),
('/press-releases','platform-center page renders + console clean')
) as t(route_path, required_evidence);
