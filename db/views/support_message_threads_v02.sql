SELECT DISTINCT ON (outlook_conversation_id, ticket_id)
	se.outlook_conversation_id AS conversation_id,
	se.case_id AS case_id, -- for backwards compatibility
	se.ticket_id AS ticket_id,
	se.ticket_type AS ticket_type,
	(SELECT jsonb_agg(DISTINCT elems)
	 FROM support_emails se2, jsonb_array_elements(recipients) AS elems
	 WHERE se2.outlook_conversation_id = se.outlook_conversation_id) AS recipients,
	se.subject AS subject,
	(SELECT se2.sent_at
	 FROM support_emails se2
	 WHERE se2.outlook_conversation_id = se.outlook_conversation_id
	 ORDER BY se2.sent_at DESC LIMIT 1) AS last_updated
FROM
	support_emails se
