(define
    (domain bank-bot)
    (:requirements         :strips :typing)
    (:types )
    (:constants )
    (:predicates
        (know__task)
        (know__account1)
        (know__account2)
        (know__funds)
        (know__goal)
        (goal)
        (have-message)
        (force-statement)
        (task-value-transfer_funds_between_accounts)
    )
    (:action get-task
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__task))
            )
        :effect
            (labeled-oneof get-task__start-task
                (outcome want-transfer
                    (and
                        (know__funds)
                        (know__task)
                        (know__account1)
                        (know__account2)
                    )
                )
                (outcome success
                    (and
                        (goal)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action confirm-transfer
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (know__task)
                (task-value-transfer_funds_between_accounts)
            )
        :effect
            (labeled-oneof confirm-transfer__set-allergy
                (outcome complete
                    (and
                        (not (know__account1))
                        (not (know__funds))
                        (have-message)
                        (not (know__task))
                        (force-statement)
                        (not (task-value-transfer_funds_between_accounts))
                        (not (know__account2))
                    )
                )
            )
    )
    (:action dialogue_statement
        :parameters()
        :precondition
            (and
                (force-statement)
                (have-message)
            )
        :effect
            (labeled-oneof dialogue_statement__reset
                (outcome lock
                    (and
                        (not (have-message))
                        (not (force-statement))
                    )
                )
            )
    )
    (:action set-task
        :parameters()
        :precondition
            (and
                (not (task-value-transfer_funds_between_accounts))
                (know__task)
            )
        :effect
            (labeled-oneof set-task__set-valid-value
                (outcome transfer_funds_between_accounts
                    (and
                        (task-value-transfer_funds_between_accounts)
                    )
                )
            )
    )
)