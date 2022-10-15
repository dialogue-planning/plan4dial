(define
    (domain day-planner)
    (:requirements         :strips :typing)
    (:types )
    (:constants )
    (:predicates
        (know__location)
        (maybe-know__location)
        (know__cuisine)
        (maybe-know__cuisine)
        (know__have_allergy)
        (have_allergy)
        (know__food_restriction)
        (know__budget)
        (know__outing_type)
        (maybe-know__outing_type)
        (know__conflict)
        (conflict)
        (know__restaurant)
        (know__outing)
        (know__goal)
        (goal)
        (have-message)
        (force-statement)
        (allow_single_slot_outing_type)
        (allow_single_slot_budget)
        (forcing__get-allergy)
    )
    (:action get-have-allergy
        :parameters()
        :precondition
            (and
                (not (forcing__get-allergy))
                (not (know__have_allergy))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         set-allergy
                (outcome indicate_allergy
                    (and
                        (know__have_allergy)
                        (forcing__get-allergy)
                        (have_allergy)
                    )
                )
                (outcome indicate_no_allergy
                    (and
                        (know__have_allergy)
                        (not (conflict))
                        (not (have_allergy))
                        (know__conflict)
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
    (:action get-allergy
        :parameters()
        :precondition
            (and
                (know__have_allergy)
                (have_allergy)
                (not (force-statement))
            )
        :effect
            (labeled-oneof         set-allergy
                (outcome update_allergy
                    (and
                        (not (forcing__get-allergy))
                        (know__food_restriction)
                    )
                )
                (outcome fallback
                    (and
                        (not (forcing__get-allergy))
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action check-conflicts
        :parameters()
        :precondition
            (and
                (know__have_allergy)
                (not (forcing__get-allergy))
                (not (force-statement))
                (know__cuisine)
                (not (maybe-know__cuisine))
                (know__food_restriction)
                (have_allergy)
                (not (know__conflict))
                (know__location)
                (not (maybe-know__location))
            )
        :effect
            (labeled-oneof         check-conflicts
                (outcome restriction-dessert
                    (and
                        (conflict)
                        (know__conflict)
                    )
                )
                (outcome restriction-mexican
                    (and
                        (conflict)
                        (know__conflict)
                    )
                )
                (outcome no-restriction-1
                    (and
                        (not (conflict))
                        (know__conflict)
                    )
                )
                (outcome no-restriction-2
                    (and
                        (not (conflict))
                        (know__conflict)
                    )
                )
                (outcome no-restriction-3
                    (and
                        (not (conflict))
                        (know__conflict)
                    )
                )
                (outcome no-restriction-4
                    (and
                        (not (conflict))
                        (know__conflict)
                    )
                )
            )
    )
    (:action reset-preferences
        :parameters()
        :precondition
            (and
                (not (forcing__get-allergy))
                (conflict)
                (know__conflict)
                (not (force-statement))
            )
        :effect
            (labeled-oneof         reset
                (outcome reset-values
                    (and
                        (not (know__food_restriction))
                        (force-statement)
                        (not (know__have_allergy))
                        (have-message)
                        (not (maybe-know__cuisine))
                        (not (know__cuisine))
                        (not (know__conflict))
                    )
                )
            )
    )
    (:action set-restaurant
        :parameters()
        :precondition
            (and
                (not (forcing__get-allergy))
                (not (conflict))
                (know__cuisine)
                (not (maybe-know__cuisine))
                (not (force-statement))
                (not (know__restaurant))
                (know__conflict)
            )
        :effect
            (labeled-oneof         assign_restaurant
                (outcome set-mexican
                    (and
                        (know__restaurant)
                    )
                )
                (outcome set-italian
                    (and
                        (know__restaurant)
                    )
                )
                (outcome set-chinese
                    (and
                        (know__restaurant)
                    )
                )
                (outcome set-dessert
                    (and
                        (know__restaurant)
                    )
                )
            )
    )
    (:action set-outing
        :parameters()
        :precondition
            (and
                (not (maybe-know__outing_type))
                (not (forcing__get-allergy))
                (not (force-statement))
                (know__budget)
                (know__outing_type)
            )
        :effect
            (labeled-oneof         assign_outing
                (outcome set-club
                    (and
                        (know__outing)
                    )
                )
                (outcome set-library
                    (and
                        (know__outing)
                    )
                )
                (outcome set-theater
                    (and
                        (know__outing)
                    )
                )
                (outcome set-golf
                    (and
                        (know__outing)
                    )
                )
            )
    )
    (:action complete
        :parameters()
        :precondition
            (and
                (know__restaurant)
                (know__outing)
                (not (forcing__get-allergy))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         finish
                (outcome finish
                    (and
                        (goal)
                        (know__goal)
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
            (labeled-oneof         reset
                (outcome lock
                    (and
                        (not (have-message))
                        (not (force-statement))
                    )
                )
            )
    )
    (:action slot-fill__get-location
        :parameters()
        :precondition
            (and
                (not (forcing__get-allergy))
                (not (force-statement))
                (not (know__location))
                (not (maybe-know__location))
            )
        :effect
            (labeled-oneof         validate-slot-fill
                (outcome location_found
                    (and
                        (force-statement)
                        (have-message)
                        (know__location)
                        (not (maybe-know__location))
                    )
                )
                (outcome location_maybe-found
                    (and
                        (maybe-know__location)
                        (not (know__location))
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
    (:action clarify__location
        :parameters()
        :precondition
            (and
                (not (forcing__get-allergy))
                (maybe-know__location)
                (not (know__location))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         validate-clarification
                (outcome confirm
                    (and
                        (know__location)
                        (not (maybe-know__location))
                    )
                )
                (outcome deny
                    (and
                        (not (know__location))
                        (not (maybe-know__location))
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
    (:action slot-fill__get-cuisine
        :parameters()
        :precondition
            (and
                (not (forcing__get-allergy))
                (not (maybe-know__cuisine))
                (not (know__cuisine))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         validate-slot-fill
                (outcome cuisine_found
                    (and
                        (know__cuisine)
                        (not (maybe-know__cuisine))
                        (have-message)
                        (force-statement)
                    )
                )
                (outcome cuisine_maybe-found
                    (and
                        (maybe-know__cuisine)
                        (not (know__cuisine))
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
    (:action clarify__cuisine
        :parameters()
        :precondition
            (and
                (not (forcing__get-allergy))
                (maybe-know__cuisine)
                (not (know__cuisine))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         validate-clarification
                (outcome confirm
                    (and
                        (know__cuisine)
                        (not (maybe-know__cuisine))
                    )
                )
                (outcome deny
                    (and
                        (not (maybe-know__cuisine))
                        (not (know__cuisine))
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
    (:action slot-fill__get_outing
        :parameters()
        :precondition
            (and
                (not (maybe-know__outing_type))
                (not (know__outing_type))
                (not (forcing__get-allergy))
                (not (force-statement))
                (not (know__budget))
            )
        :effect
            (labeled-oneof         validate-slot-fill
                (outcome budget_found-outing_type_found
                    (and
                        (not (maybe-know__outing_type))
                        (know__budget)
                        (know__outing_type)
                    )
                )
                (outcome budget_found-outing_type_maybe-found
                    (and
                        (maybe-know__outing_type)
                        (know__budget)
                        (not (know__outing_type))
                    )
                )
                (outcome budget_found
                    (and
                        (know__budget)
                        (have-message)
                        (allow_single_slot_outing_type)
                        (force-statement)
                    )
                )
                (outcome outing_type_found
                    (and
                        (not (maybe-know__outing_type))
                        (force-statement)
                        (allow_single_slot_budget)
                        (have-message)
                        (know__outing_type)
                    )
                )
                (outcome outing_type_maybe-found
                    (and
                        (maybe-know__outing_type)
                        (allow_single_slot_budget)
                        (not (know__outing_type))
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
    (:action single_slot__outing_type
        :parameters()
        :precondition
            (and
                (not (maybe-know__outing_type))
                (not (know__outing_type))
                (not (forcing__get-allergy))
                (allow_single_slot_outing_type)
                (not (force-statement))
            )
        :effect
            (labeled-oneof         validate-slot-fill
                (outcome fill-slot
                    (and
                        (not (maybe-know__outing_type))
                        (not (allow_single_slot_outing_type))
                        (know__outing_type)
                    )
                )
                (outcome slot-unclear
                    (and
                        (maybe-know__outing_type)
                        (not (know__outing_type))
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
    (:action single_slot__budget
        :parameters()
        :precondition
            (and
                (not (forcing__get-allergy))
                (allow_single_slot_budget)
                (not (know__budget))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         validate-slot-fill
                (outcome fill-slot
                    (and
                        (know__budget)
                        (not (allow_single_slot_budget))
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
    (:action clarify__outing_type
        :parameters()
        :precondition
            (and
                (not (forcing__get-allergy))
                (maybe-know__outing_type)
                (not (know__outing_type))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         validate-clarification
                (outcome confirm
                    (and
                        (not (maybe-know__outing_type))
                        (know__outing_type)
                    )
                )
                (outcome deny
                    (and
                        (not (maybe-know__outing_type))
                        (not (know__outing_type))
                        (allow_single_slot_outing_type)
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
