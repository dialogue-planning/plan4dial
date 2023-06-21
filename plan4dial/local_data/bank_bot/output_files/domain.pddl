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
                (not (force-statement))
                (not (know__task))
            )
        :effect
            (labeled-oneof         slot-fill__get-task__validate-slot-fill
                (outcome task_found
                    (and
                        (know__task)
                        (know__goal)
                        (goal)
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
)