(define
    (domain day-planner-reversed-utterances)
    (:requirements         :strips :typing)
    (:types )
    (:constants )
    (:predicates
        (know__location)
        (know__phone_number)
        (maybe-know__phone_number)
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
                (not (force-statement))
                (not (know__have_allergy))
                (not (forcing__get-allergy))
            )
        :effect
            (labeled-oneof         get-have-allergy__set-allergy
                (outcome indicate_allergy
                    (and
                        (have_allergy)
                        (forcing__get-allergy)
                        (know__have_allergy)
                    )
                )
                (outcome indicate_no_allergy
                    (and
                        (know__conflict)
                        (not (conflict))
                        (not (have_allergy))
                        (know__have_allergy)
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
    (:action get-allergy
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (have_allergy)
                (know__have_allergy)
            )
        :effect
            (labeled-oneof         get-allergy__set-allergy
                (outcome update_allergy
                    (and
                        (not (forcing__get-allergy))
                        (know__food_restriction)
                    )
                )
                (outcome fallback
                    (and
                        (not (forcing__get-allergy))
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action check-conflicts
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (forcing__get-allergy))
                (not (maybe-know__cuisine))
                (know__have_allergy)
                (not (know__conflict))
                (know__food_restriction)
                (have_allergy)
                (know__cuisine)
                (know__location)
            )
        :effect
            (labeled-oneof         check-conflicts__check-conflicts
                (outcome restriction-dessert
                    (and
                        (know__conflict)
                        (conflict)
                    )
                )
                (outcome restriction-mexican
                    (and
                        (know__conflict)
                        (conflict)
                    )
                )
                (outcome no-restriction-1
                    (and
                        (know__conflict)
                        (not (conflict))
                    )
                )
                (outcome no-restriction-2
                    (and
                        (know__conflict)
                        (not (conflict))
                    )
                )
                (outcome no-restriction-3
                    (and
                        (know__conflict)
                        (not (conflict))
                    )
                )
                (outcome no-restriction-4
                    (and
                        (know__conflict)
                        (not (conflict))
                    )
                )
            )
    )
    (:action reset-preferences
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (know__conflict)
                (conflict)
                (not (forcing__get-allergy))
            )
        :effect
            (labeled-oneof         reset-preferences__reset
                (outcome reset-values
                    (and
                        (not (maybe-know__cuisine))
                        (not (know__conflict))
                        (force-statement)
                        (not (know__have_allergy))
                        (not (know__cuisine))
                        (have-message)
                        (not (know__food_restriction))
                    )
                )
            )
    )
    (:action set-restaurant
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (forcing__get-allergy))
                (not (maybe-know__cuisine))
                (not (conflict))
                (not (know__restaurant))
                (know__cuisine)
                (know__conflict)
            )
        :effect
            (labeled-oneof         set-restaurant__assign_restaurant
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
                (not (force-statement))
                (not (forcing__get-allergy))
                (know__budget)
                (know__outing_type)
                (not (maybe-know__outing_type))
            )
        :effect
            (labeled-oneof         set-outing__assign_outing
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
                (not (force-statement))
                (not (forcing__get-allergy))
                (know__phone_number)
                (not (maybe-know__phone_number))
                (know__outing)
                (know__restaurant)
                (know__location)
            )
        :effect
            (labeled-oneof         complete__finish
                (outcome finish
                    (and
                        (know__goal)
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
            (labeled-oneof         dialogue_statement__reset
                (outcome lock
                    (and
                        (not (force-statement))
                        (not (have-message))
                    )
                )
            )
    )
    (:action slot-fill__get-location
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__location))
                (not (forcing__get-allergy))
            )
        :effect
            (labeled-oneof         slot-fill__get-location__validate-slot-fill
                (outcome location_found
                    (and
                        (force-statement)
                        (have-message)
                        (know__location)
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
    (:action slot-fill__get-phone_number
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__phone_number))
                (not (forcing__get-allergy))
                (not (maybe-know__phone_number))
            )
        :effect
            (labeled-oneof         slot-fill__get-phone_number__validate-slot-fill
                (outcome phone_number_found
                    (and
                        (know__phone_number)
                        (not (maybe-know__phone_number))
                    )
                )
                (outcome phone_number_maybe-found
                    (and
                        (not (know__phone_number))
                        (maybe-know__phone_number)
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
    (:action clarify__phone_number
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__phone_number))
                (not (forcing__get-allergy))
                (maybe-know__phone_number)
            )
        :effect
            (labeled-oneof         clarify__phone_number__validate-clarification
                (outcome confirm
                    (and
                        (know__phone_number)
                        (not (maybe-know__phone_number))
                    )
                )
                (outcome deny
                    (and
                        (not (know__phone_number))
                        (not (maybe-know__phone_number))
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
    (:action slot-fill__get-cuisine
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__cuisine))
                (not (maybe-know__cuisine))
                (not (forcing__get-allergy))
            )
        :effect
            (labeled-oneof         slot-fill__get-cuisine__validate-slot-fill
                (outcome cuisine_found
                    (and
                        (know__cuisine)
                        (not (maybe-know__cuisine))
                        (force-statement)
                        (have-message)
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
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action clarify__cuisine
        :parameters()
        :precondition
            (and
                (maybe-know__cuisine)
                (not (know__cuisine))
                (not (forcing__get-allergy))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         clarify__cuisine__validate-clarification
                (outcome confirm
                    (and
                        (know__cuisine)
                        (not (maybe-know__cuisine))
                        (force-statement)
                        (have-message)
                    )
                )
                (outcome deny
                    (and
                        (not (know__cuisine))
                        (not (maybe-know__cuisine))
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
    (:action slot-fill__get_outing
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (forcing__get-allergy))
                (not (know__outing_type))
                (not (know__budget))
                (not (maybe-know__outing_type))
            )
        :effect
            (labeled-oneof         slot-fill__get_outing__validate-slot-fill
                (outcome budget_found-outing_type_found
                    (and
                        (know__budget)
                        (know__outing_type)
                        (not (maybe-know__outing_type))
                    )
                )
                (outcome budget_found-outing_type_maybe-found
                    (and
                        (know__budget)
                        (not (know__outing_type))
                        (maybe-know__outing_type)
                    )
                )
                (outcome budget_found
                    (and
                        (know__budget)
                        (force-statement)
                        (have-message)
                        (allow_single_slot_outing_type)
                    )
                )
                (outcome outing_type_found
                    (and
                        (force-statement)
                        (allow_single_slot_budget)
                        (have-message)
                        (know__outing_type)
                        (not (maybe-know__outing_type))
                    )
                )
                (outcome outing_type_maybe-found
                    (and
                        (not (know__outing_type))
                        (allow_single_slot_budget)
                        (maybe-know__outing_type)
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
    (:action single_slot__outing_type
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (forcing__get-allergy))
                (allow_single_slot_outing_type)
                (not (know__outing_type))
                (not (maybe-know__outing_type))
            )
        :effect
            (labeled-oneof         single_slot__outing_type__validate-slot-fill
                (outcome fill-slot
                    (and
                        (know__outing_type)
                        (force-statement)
                        (have-message)
                        (not (maybe-know__outing_type))
                    )
                )
                (outcome slot-unclear
                    (and
                        (not (know__outing_type))
                        (maybe-know__outing_type)
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
    (:action single_slot__budget
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__budget))
                (allow_single_slot_budget)
                (not (forcing__get-allergy))
            )
        :effect
            (labeled-oneof         single_slot__budget__validate-slot-fill
                (outcome fill-slot
                    (and
                        (know__budget)
                        (force-statement)
                        (have-message)
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
    (:action clarify__outing_type
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__outing_type))
                (not (forcing__get-allergy))
                (maybe-know__outing_type)
            )
        :effect
            (labeled-oneof         clarify__outing_type__validate-clarification
                (outcome confirm
                    (and
                        (know__outing_type)
                        (force-statement)
                        (have-message)
                        (not (maybe-know__outing_type))
                    )
                )
                (outcome deny
                    (and
                        (allow_single_slot_outing_type)
                        (not (know__outing_type))
                        (not (maybe-know__outing_type))
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
)