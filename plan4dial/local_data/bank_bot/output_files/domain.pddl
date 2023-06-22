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
    (:action get-transfer-settings
        :parameters()
        :precondition
            (and
                (not (know__funds))
                (not (know__account1))
                (task-value-transfer_funds_between_accounts)
                (know__task)
                (not (force-statement))
                (not (know__account2))
            )
        :effect
            (labeled-oneof         get-transfer-settings__validate
                (outcome complete-transfer
                    (and
                        (know__account1)
                        (know__account2)
                        (know__funds)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action confirm-transfer
        :parameters()
        :precondition
            (and
                (know__account1)
                (know__account2)
                (not (force-statement))
                (know__funds)
            )
        :effect
            (labeled-oneof         confirm-transfer__set-allergy
                (outcome complete-transfer
                    (and
                        (goal)
                        (not (know__funds))
                        (not (know__account1))
                        (not (know__account2))
                    )
                )
            )
    )
    (:action dialogue_statement
        :parameters()
        :precondition
            (and
                (have-message)
                (force-statement)
            )
        :effect
            (labeled-oneof         dialogue_statement__reset
                (outcome lock
                    (and
                        (not (force-statement))
                        (not (have-message))
                    )
                )
            )
    )
    (:action slot-fill__get-task
        :parameters()
        :precondition
            (and
                (not (know__task))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         slot-fill__get-task__validate-slot-fill
                (outcome task_found
                    (and
                        (know__task)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action set-task
        :parameters()
        :precondition
            (and
                (know__task)
                (not (task-value-transfer_funds_between_accounts))
            )
        :effect
            (labeled-oneof         set-task__set-valid-value
                (outcome transfer_funds_between_accounts
                    (and
                        (task-value-transfer_funds_between_accounts)
                    )
                )
            )
    )
)