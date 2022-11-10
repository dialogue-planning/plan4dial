(define
    (domain order-pizza)
    (:requirements         :strips :typing)
    (:types )
    (:constants )
    (:predicates
        (know__invited-talk)
        (know__morning-session)
        (know__early-afternoon-session)
        (know__afternoon-session)
        (know__evening-session)
        (goal)
        (have-message)
        (force-statement)
    )
    (:action get-invited-talk
        :parameters()
        :precondition
            (and
                (not (know__invited-talk))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         set-invited-talk
                (outcome valid
                    (and
                        (know__invited-talk)
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
    (:action get-morning-session
        :parameters()
        :precondition
            (and
                (not (know__morning-session))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         set-morning-session
                (outcome valid
                    (and
                        (know__morning-session)
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
    (:action get-early-afternoon-session
        :parameters()
        :precondition
            (and
                (not (know__early-afternoon-session))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         set-early-afternoon-session
                (outcome valid
                    (and
                        (know__early-afternoon-session)
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
    (:action get-afternoon-session
        :parameters()
        :precondition
            (and
                (not (know__afternoon-session))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         set-afternoon-session
                (outcome valid
                    (and
                        (know__afternoon-session)
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
    (:action get-evening-session
        :parameters()
        :precondition
            (and
                (not (know__evening-session))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         set-evening-session
                (outcome valid
                    (and
                        (know__evening-session)
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
    (:action complete
        :parameters()
        :precondition
            (and
                (know__afternoon-session)
                (know__invited-talk)
                (not (force-statement))
                (know__early-afternoon-session)
                (know__morning-session)
                (know__evening-session)
            )
        :effect
            (labeled-oneof         goal
                (outcome valid
                    (and
                        (goal)
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
            (labeled-oneof         reset
                (outcome lock
                    (and
                        (not (force-statement))
                        (not (have-message))
                    )
                )
            )
    )
)