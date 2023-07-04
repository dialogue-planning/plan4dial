(define
    (domain icaps-intro-planner)
    (:requirements         :strips :typing)
    (:types )
    (:constants )
    (:predicates
        (know__attending-8)
        (attending-8)
        (know__attending-dc)
        (attending-dc)
        (know__dc-interest)
        (know__attending-workshop-tut)
        (attending-workshop-tut)
        (know__workshop-pref)
        (know__attending-rec)
        (goal)
        (have-message)
        (force-statement)
        (forcing__slot-fill__ask-monday-evening)
    )
    (:action complete
        :parameters()
        :precondition
            (and
                (know__attending-rec)
                (know__workshop-pref)
                (not (forcing__slot-fill__ask-monday-evening))
                (know__dc-interest)
                (not (force-statement))
            )
        :effect
            (labeled-oneof         complete__complete
                (outcome complete
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
    (:action slot-fill__ask-july-8
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (forcing__slot-fill__ask-monday-evening))
                (not (know__attending-8))
            )
        :effect
            (labeled-oneof         slot-fill__ask-july-8__get-response
                (outcome confirm_outcome
                    (and
                        (know__attending-8)
                        (attending-8)
                    )
                )
                (outcome deny_outcome
                    (and
                        (not (attending-dc))
                        (know__attending-8)
                        (know__attending-dc)
                        (have-message)
                        (know__dc-interest)
                        (not (attending-8))
                        (force-statement)
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
    (:action slot-fill__ask-dc
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (forcing__slot-fill__ask-monday-evening))
                (not (know__attending-dc))
                (attending-8)
            )
        :effect
            (labeled-oneof         slot-fill__ask-dc__get-response
                (outcome confirm_outcome
                    (and
                        (attending-dc)
                        (know__attending-dc)
                    )
                )
                (outcome deny_outcome
                    (and
                        (know__dc-interest)
                        (not (attending-dc))
                        (know__attending-dc)
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
    (:action slot-fill__ask-dc-pref
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (forcing__slot-fill__ask-monday-evening))
                (attending-dc)
                (not (know__dc-interest))
            )
        :effect
            (labeled-oneof         slot-fill__ask-dc-pref__validate-slot-fill
                (outcome dc-interest_found
                    (and
                        (have-message)
                        (force-statement)
                        (know__dc-interest)
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
    (:action slot-fill__ask-workshop-tut
        :parameters()
        :precondition
            (and
                (not (know__attending-workshop-tut))
                (not (forcing__slot-fill__ask-monday-evening))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         slot-fill__ask-workshop-tut__get-response
                (outcome confirm_outcome
                    (and
                        (forcing__slot-fill__ask-monday-evening)
                        (know__attending-workshop-tut)
                        (attending-workshop-tut)
                    )
                )
                (outcome deny_outcome
                    (and
                        (know__attending-workshop-tut)
                        (know__workshop-pref)
                        (have-message)
                        (not (attending-workshop-tut))
                        (force-statement)
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
    (:action slot-fill__ask-workshop-pref
        :parameters()
        :precondition
            (and
                (not (know__workshop-pref))
                (not (force-statement))
                (not (forcing__slot-fill__ask-monday-evening))
                (attending-workshop-tut)
            )
        :effect
            (labeled-oneof         slot-fill__ask-workshop-pref__validate-slot-fill
                (outcome workshop-pref_found
                    (and
                        (have-message)
                        (force-statement)
                        (know__workshop-pref)
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
    (:action slot-fill__ask-monday-evening
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__attending-rec))
            )
        :effect
            (labeled-oneof         slot-fill__ask-monday-evening__validate-slot-fill
                (outcome attending-rec_found
                    (and
                        (know__attending-rec)
                        (not (forcing__slot-fill__ask-monday-evening))
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                        (not (forcing__slot-fill__ask-monday-evening))
                    )
                )
            )
    )
)